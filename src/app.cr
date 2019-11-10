require "./textui/*"
require "pg"
require "mysql"
require "sqlite3"
require "uri"

require "./results_control"
require "./query_control"

class App
  delegate error, info, to: @status_bar

  @db : DB::Database

  def initialize(@db_uri : URI)
    @db = DB.open(@db_uri)
    @ui = TextUi::Ui.new
    @ui.on_resize(->handle_resize(Int32, Int32))
    @ui.key_input_handler = ->handle_key_input(Char, UInt16)

    @query_ctl = QueryControl.new(@ui)
    @query_ctl.on_database_selected = ->change_database(String)
    @results_ctl = ResultsControl.new(@ui)
    @status_bar = TextUi::StatusBar.new(@ui)

    setup_shortcuts
  end

  def main_loop
    populate_database_list
    @ui.main_loop
  rescue
    @ui.shutdown!
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

  private def handle_key_input(_chr, key) : Nil
    case key
    when TextUi::KEY_CTRL_X then @ui.shutdown!
    when TextUi::KEY_CTRL_C then copy_query
    when TextUi::KEY_CTRL_R then copy_results
    when TextUi::KEY_CTRL_B then beautify
    when TextUi::KEY_CTRL_S then save_csv
    when TextUi::KEY_F1     then show_help
    when TextUi::KEY_F5     then execute_query(@query_ctl.query)
    end
  end

  private def copy_query
    copy_to_clipboard(@query_ctl.query)
    info("Results copied to clipboard!")
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
    error("not implemnted yet")
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
    info("Visit http://www.google.com ;-)")
  end

  private def execute_query(query)
    rows = Array(Array(String)).new
    @db.query(query) do |rs|
      @results_ctl.clear
      rows << rs.column_names
      rs.each do
        row = [] of String
        rs.column_count.times { row << rs.read.to_s }
        rows << row
      end
      @results_ctl.set_data(rows)
    end
  rescue e
    error(e.message.to_s)
  end

  private def fetch_database_list
    databases = [] of String
    query = case @db_uri.scheme
            when "postgres", "postgresql" then "SELECT datname FROM pg_database"
            when "sqlite3"                then return [current_database_name]
            when "mysql"                  then "SHOW DATABASES"
            else
              raise "Database not supported, please, file a bug."
            end
    @db.query(query) do |rs|
      rs.each do
        databases << rs.read(String)
      end
    end
    return databases
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
