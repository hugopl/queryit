require "./textui/*"
require "pg"
require "mysql"
require "sqlite3"
require "uri"

require "./results"

class App
  delegate main_loop, to: @ui

  @db : DB::Database

  def initialize(@db_uri : URI)
    @db = DB.open(@db_uri)
    @ui = TextUi::Ui.new
    @ui.on_resize(->handle_resize(Int32, Int32))
    @ui.key_input_handler = ->handle_key_input(Char, UInt16)

    @query_box = TextUi::Box.new(@ui, "Query", "F2")
    @label = TextUi::Label.new(@query_box, 1, 1, "SELECT * FROM users;")
    @label.accept_input
    @label.cursor = @label.text.size
    @ui.focus(@label)

    @database_list_box = TextUi::Box.new(@ui, "Databases", "F3")
    @database_list = TextUi::List.new(@database_list_box, 1, 1, populate_database_list)
    @database_list.select(current_database_name)
    @database_list.width = 18
    @database_list.on_select = ->change_database(String)

    @results = Results.new(@ui)
    @shortcut_bar = TextUi::ShortcutBar.new(@ui)

    setup_shortcuts
  end

  private def current_database_name
    @db_uri.path[1..-1]
  end

  private def handle_resize(width, height)
    @query_box.width = width - 19
    @query_box.height = height//2
    @label.width = @query_box.width - 2
    @label.height = @query_box.height - 2

    @database_list_box.width = 20
    @database_list_box.height = height//2
    @database_list_box.right_of(@query_box)
    @database_list.height = @database_list_box.height - 2

    @results.y = @query_box.height
    @results.width = width
    @results.height = height - @query_box.height - 1

    @shortcut_bar.y = height - 1
    @shortcut_bar.width = width
  end

  private def setup_shortcuts
    @ui.add_focus_shortcut(TextUi::KEY_F2, @label)
    @ui.add_focus_shortcut(TextUi::KEY_F3, @database_list)

    @shortcut_bar.add_shortcut("^X", "Exit")
    @shortcut_bar.add_shortcut("^C", "Copy Query")
    @shortcut_bar.add_shortcut("^R", "Copy Results")
    @shortcut_bar.add_shortcut("^B", "Beautify")
    @shortcut_bar.add_shortcut("F12", "Save CSV")
    @shortcut_bar.add_shortcut("F1", "Help")
  end

  private def handle_key_input(_chr, key) : Nil
    case key
    when TextUi::KEY_CTRL_X then @ui.shutdown!
    when TextUi::KEY_F5     then execute_query(@label.text)
    end
  end

  private def execute_query(query)
    debug(query)
    rows = Array(Array(String)).new
    @db.query(query) do |rs|
      @results.clear
      rows << rs.column_names
      rs.each do
        row = [] of String
        rs.column_count.times { row << rs.read.to_s }
        rows << row
      end
      @results.set_data(rows)
    end
  rescue e
    error(e.message.to_s)
  end

  private def populate_database_list
    databases = [] of String
    debug @db_uri.scheme
    query = case @db_uri.scheme
            when "postgres", "postgresql" then "SELECT datname FROM pg_database"
            when "sqlite"                 then return [current_database_name]
            when "mysql"                  then "SHOW DATABASES"
            else
              raise "Database not supported, please, file a bug."
            end
    @db.query(query) do |rs|
      rs.each do
        databases << rs.read(String)
      end
    end
    databases
  end

  private def change_database(database_name : String) : Nil
    new_db_uri = @db_uri.dup
    new_db_uri.path = "/#{database_name}"
    new_db = DB.open(new_db_uri)
    @db.close
    @db = new_db
    @db_uri = new_db_uri
  rescue e : DB::ConnectionRefused
    error("Unable to connect to #{database_name}!")
    @database_list.select(current_database_name)
  end

  private def error(message : String) : Nil
    debug(message)
  end
end
