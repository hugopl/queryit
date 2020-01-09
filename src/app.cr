require "textui"
require "pg"
require "mysql"
require "sqlite3"
require "uri"

require "./config"
require "./results_control"
require "./query_control"
require "./sql_beautifier/sql_beautifier"

class AppError < Exception
end

class App
  delegate error, info, to: @status_bar

  @db : DB::Database
  @focusable_widgets : Array(TextUi::Widget)?

  @config = Config.new
  @ui = TextUi::Ui.new

  def initialize(@db_uri : URI)
    @db = DB.open(@db_uri)
    @ui.resized.on(&->handle_resize(Int32, Int32))
    @ui.key_typed.on(&->on_key_typed(TextUi::KeyEvent))

    load_config

    @query_ctl = QueryControl.new(@ui)
    @query_ctl.query = @config.last_query[@db_uri.to_s]?.to_s
    @query_ctl.on_database_selected = ->change_database(String)
    @results_ctl = ResultsControl.new(@ui)
    @status_bar = TextUi::StatusBar.new(@ui)

    setup_shortcuts
  end

  private def load_config
    @config = Config.from_yaml(File.read(config_file_path))
  rescue
    nil
  end

  def config_file_path
    Path.home.join(".queryit")
  end

  private def save_config
    @config.last_query[@db_uri.to_s] = @query_ctl.query
    File.write(config_file_path, @config.to_yaml)
  end

  def main_loop
    populate_database_list
    @ui.main_loop
    save_config
  end

  private def current_database_name
    @db_uri.path[1..-1]
  end

  private def handle_resize(width, height)
    @query_ctl.handle_resize(width, height)
    @results_ctl.handle_resize(width, height)

    @status_bar.y = height - 1
    @status_bar.width = width
  end

  private def setup_shortcuts
    @status_bar.add_shortcut("^X", "Exit")
    @status_bar.add_shortcut("^C", "Copy Query")
    @status_bar.add_shortcut("^R", "Copy Results")
    @status_bar.add_shortcut("^B", "Beautify")
    @status_bar.add_shortcut("F5", "Execute")
    @status_bar.add_shortcut("^S", "Save CSV")
    @status_bar.add_shortcut("F1", "Help")
  end

  private def on_key_typed(event) : Nil
    case event.key
    when TextUi::KEY_CTRL_X then @ui.shutdown!
    when TextUi::KEY_CTRL_C then copy_query
    when TextUi::KEY_CTRL_R then copy_results
    when TextUi::KEY_CTRL_B then beautify
    when TextUi::KEY_CTRL_S then save_csv
    when TextUi::KEY_F1
      event.accept
      show_help
    when TextUi::KEY_F5  then execute_query(@query_ctl.query)
    when TextUi::KEY_TAB then cycle_focus
    end
  end

  private def focusable_widgets : Array(TextUi::Widget)
    @focusable_widgets ||= @query_ctl.focusable_widgets + @results_ctl.focusable_widgets
  end

  private def cycle_focus
    focus_next = false
    focusable_widgets.each.cycle.each_with_index do |widget, i|
      return @ui.focus(widget) if focus_next
      focus_next = widget.focused?

      return @ui.focus(focusable_widgets.first) if i > focusable_widgets.size
    end
  end

  private def copy_query
    copy_to_clipboard(@query_ctl.query)
    info("Query copied to clipboard!")
  end

  private def copy_results
    return if @results_ctl.empty?

    copy_to_clipboard(@results_ctl.to_csv.to_s)
    info("Results copied to clipboard!")
  end

  private def copy_to_clipboard(contents : String)
    input = IO::Memory.new(contents)
    # TODO: Do a tiny OS abstraction for this
    Process.run("xclip", %w(-selection clipboard -in), input: input)
  rescue
    error("xclip not found")
  end

  private def beautify
    @query_ctl.query = SQLBeautifier.beautify(@query_ctl.query)
  rescue
    error("Can't beautify this query, sorry :-(")
  end

  private def save_csv
    contents = @results_ctl.to_csv
    i = 0
    filename = "results.csv"
    loop do
      filename = "results_#{i}.csv" if i > 0
      i += 1
      next if File.exists?(filename)

      File.write(filename, contents)
      break
    end
    info("Results saved to #{filename}.")
  end

  private def show_help
    help_text = <<-'HELP'
                            SQL JOINS CHEATSHEET
           _..----.._  _..----.._         A:
        _-'          '-_         '-_      SELECT * FROM A
      .'           .'   '.          '.      LEFT JOIN B ON A.key = B.key
     /            /       \           \
    |            |         |           |  B:
    |      A     |    C    |     B     |  SELECT * FROM B
    |            |         |           |    LEFT JOIN A ON B.key = A.key
     \            \       /           /
      '.           '.   .'          .'    C:
        `-._        _--'_       _.-'      SELECT * FROM A
            `"----"`     "----"`           INNER JOIN B ON A.key = B.key
                                SHORTCUTS
      CTRL+L    Clear query editor
      CTRL+/    (Un)Comment lines
    HELP
    size = TextUi::Widget.text_dimensions(help_text, @ui.width - 2, @ui.height - 2)
    dialog = TextUi::Dialog.new(@ui, "Queryit v#{VERSION} - Help")
    dialog.resize(size[:width] + 2, size[:height] + 2)
    label = TextUi::Label.new(dialog, 1, 1, help_text)
    label.resize(size[:width], size[:height])
    old_focus = @ui.focused_widget
    @ui.focus(dialog)
    dialog.dismissed.on { @ui.focus(old_focus) }
  end

  private def execute_query(query)
    @results_ctl.clear

    rows = Array(Array(String)).new
    result_set = nil
    elapsed_time = Time.measure do
      result_set = @db.query(query)
    end
    return if result_set.nil?

    rows << result_set.column_names
    result_set.each do
      row = [] of String
      result_set.column_count.times { row << result_set.read.to_s }
      rows << row
    end
    result_set.close

    if query =~ /\A\s*explain\s+/i
      @results_ctl.explain(rows.map(&.first).join("\n"))
    else
      @results_ctl.set_data(rows)
    end
    @results_ctl.elapsed_time = elapsed_time
  rescue e
    @results_ctl.show_error(e.message.to_s)
  ensure
    result_set.try(&.close)
  end

  private def fetch_database_list
    query = case @db_uri.scheme
            when "postgres", "postgresql" then "SELECT datname FROM pg_database"
            when "sqlite3"                then return [current_database_name]
            when "mysql"                  then "SHOW DATABASES"
            else
              raise AppError.new("Database not supported, please, file a bug.")
            end

    databases = [] of String
    @db.query(query) do |rs|
      rs.each do
        databases << rs.read(String)
      end
    end
    databases
  end

  private def populate_database_list
    @query_ctl.available_databases = fetch_database_list
    @query_ctl.selected_database = current_database_name
  end

  private def change_database(database_name : String) : Nil
    return if current_database_name == database_name

    new_db_uri = @db_uri.dup
    new_db_uri.path = "/#{database_name}"
    new_db = DB.open(new_db_uri)
    @db.close
    @db = new_db
    @db_uri = new_db_uri
  rescue e : DB::ConnectionRefused
    error("Unable to connect to #{database_name}!")
    @query_ctl.selected_database = current_database_name
  end
end
