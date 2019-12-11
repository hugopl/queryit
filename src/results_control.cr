require "csv"

class ResultsControl
  delegate clear, to: @table
  delegate set_data, to: @table

  def initialize(ui : TextUi::Ui)
    @box = TextUi::Box.new(ui, "Results", "F4")
    @box.border_style = TextUi::Box::BorderStyle::Fancy
    @table = TextUi::Table.new(@box, 1, 1)
    @label = TextUi::Label.new(@box, 1, 1)
    @label.visible = false
    ui.add_focus_shortcut(TextUi::KEY_F4, @table)
  end

  def focusable_widgets
    [@table]
  end

  def empty?
    @table.rows.empty?
  end

  def set_data(data)
    @table.set_data(data)
    @table.visible = true
    @label.visible = false
  end

  def to_csv
    CSV.build do |csv|
      csv.row(@table.column_names)
      @table.rows.each do |row|
        csv.row(row)
      end
    end
  end

  def handle_resize(width, height)
    half_screen = height//2
    @box.y = half_screen
    @box.width = width
    @table.width = width - 2
    @box.height = height - half_screen - 1
    @table.height = @box.height - 2
    @label.width = @table.width
    @label.height = @table.height
  end

  def show_error(message : String)
    show_text(message, TextUi::Format.new(TextUi::Color::Red))
  end

  def explain(sql_explain : String)
    show_text(sql_explain, TextUi::Format.new(TextUi::Color::White))
  end

  private def show_text(text : String, format : TextUi::Format)
    @table.clear # clear old data
    @table.erase
    @label.text = text
    @label.default_format = format
    @label.visible = true
    @table.visible = false
  end
end
