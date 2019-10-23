require "./textui/*"
require "pg"
require "uri"

class App
  delegate main_loop, to: @ui

  @db : DB::Database
  @current_database : String

  def initialize(uri : URI)
    @current_database = uri.path[1..-1]
    @db = DB.open(uri)
    @ui = TextUi::Ui.new
    @ui.on_resize(->handle_resize(Int32, Int32))
    @ui.key_input_handler = ->handle_key_input(Char, UInt16)

    @query_box = TextUi::Box.new(@ui, "Query")
    @label = TextUi::Label.new(@query_box, 1, 1, "SELECT E'123456';")
    @label.accept_input
    @label.cursor = @label.text.size
    @ui.focus(@label)

    @database_list_box = TextUi::Box.new(@ui, "Databases")
    @database_list = TextUi::List.new(@database_list_box, 1, 1, populate_database_list)
    @database_list.select(@current_database)
    @database_list.width = 18

    @result_box = TextUi::Box.new(@ui, "Results")
    @table = TextUi::Table.new(@result_box, 1, 1)
    @status = TextUi::Label.new(@ui, 0, 0, "status bar")

    setup_shortcuts
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

    @result_box.y = @query_box.height
    @result_box.width = width
    @result_box.height = height - @query_box.height - 1
    @table.width = @result_box.width - 2
    @table.height = @result_box.height - 2
    @status.y = height - 1
    @status.width = width
  end

  private def setup_shortcuts
    @ui.add_focus_shortcut(TextUi::KEY_F2, @label)
    @ui.add_focus_shortcut(TextUi::KEY_F3, @database_list)
    @ui.add_focus_shortcut(TextUi::KEY_F4, @result_box)
  end

  private def handle_key_input(_chr, key) : Nil
    case key
    when TextUi::KEY_CTRL_C then @ui.shutdown!
    when TextUi::KEY_F5     then execute_query(@label.text)
    end
  end

  private def execute_query(query)
    debug(query)
    @db.query(query) do |rs|
      @status.text = "#{rs.rows_affected} rows affected."
      @table.clear
      @table.column_names = rs.column_names
      rs.each do
        row = [] of String
        rs.column_count.times do
          row << rs.read.to_s
        end
        @table.rows << row
      end
    end
    @status.backgroundColor = TextUi::Color::Black
  rescue e : PQ::PQError
    @status.backgroundColor = TextUi::Color::Red
    @status.text = e.message.to_s
  end

  private def populate_database_list
    databases = [] of String
    @db.query("SELECT datname FROM pg_database") do |rs|
      rs.each do
        databases << rs.read(String)
      end
    end
    databases
  end
end
