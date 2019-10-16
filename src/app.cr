require "./textui/*"

class App
  delegate main_loop, to: @ui

  def initialize(@db : DB::Database)
    @ui = TextUi::Ui.new
    @ui.on_resize(->handle_resize(Int32, Int32))
    @ui.on_key_input(->handle_key_input(Char, UInt16))

    @query_box = TextUi::Box.new(@ui, "Query")
    @label = TextUi::Label.new(@query_box, 1, 1, "SELECT E'123456';")
    @label.accept_input
    @label.cursor = @label.text.size
    @ui.focus(@label)

    @result_box = TextUi::Box.new(@ui, "Results")
    @table = TextUi::Table.new(@result_box, 1, 1)
    @status = TextUi::Label.new(@ui, 0, 0, "status bar")
  end

  private def handle_resize(width, height)
    @query_box.width = width
    @query_box.height = height//2
    @label.width = @query_box.width - 2
    @label.height = @query_box.height - 2
    @result_box.y = @query_box.height
    @result_box.width = width
    @result_box.height = height - @query_box.height - 1
    @table.width = @result_box.width - 2
    @table.height = @result_box.height - 2
    @status.y = height - 1
    @status.width = width
  end

  private def handle_key_input(_chr, key)
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
        debug(row)
      end
    end
    @status.backgroundColor = TextUi::Color::Black
  rescue e : PQ::PQError
    @status.backgroundColor = TextUi::Color::Red
    @status.text = e.message.to_s
  end
end
