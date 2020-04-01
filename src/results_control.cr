require "csv"

class ResultsControl
  def initialize(ui : TextUi::Ui)
    @box = TextUi::Box.new(ui, "Results", "F4")
    @box.border_style = TextUi::Box::BorderStyle::Fancy
    @stack = TextUi::StackedWidget.new(@box, 1, 1)
    @table = TextUi::Table.new(@stack)
    @label = TextUi::Label.new(@stack)
    @label.visible = false

    @table.enter_pressed.on(&->show_result_overlay(String))
  end

  def focusable_widgets
    [@table]
  end

  def focus_table
    @table.focus
  end

  def empty?
    @table.rows.empty?
  end

  def set_data(data)
    @table.set_data(data)
    @stack.current_widget = @table
  end

  def clear
    @table.clear
    @box.footer = ""
  end

  def to_csv
    CSV.build do |csv|
      csv.row(@table.column_names)
      @table.rows.each do |row|
        csv.row(row)
      end
    end
  end

  def export_output : String
    if @label.visible?
      @label.text
    elsif empty?
      ""
    else
      to_csv
    end
  end

  def handle_resize(width, height)
    half_screen = height//2
    @box.y = half_screen
    @box.width = width
    @box.height = height - half_screen - 1

    @stack.width = width - 2
    @stack.height = @box.height - 2

    @table.width = @stack.width
    @table.height = @stack.height
    @label.width = @stack.width
    @label.height = @stack.height
  end

  def show_error(message : String)
    show_text(message, TextUi::Format.new(TextUi::Color::Red))
  end

  def explain(sql_explain : String)
    show_text(sql_explain, TextUi::Format.new(TextUi::Color::White))
  end

  def elapsed_time=(time)
    rows = @table.rows.size
    @box.footer = if rows == 1
                    "1 row in #{time.total_seconds.humanize}s"
                  elsif rows > 0
                    "#{rows} rows in #{time.total_seconds.humanize}s"
                  else
                    "#{time.total_seconds.humanize}s"
                  end
  end

  private def show_text(text : String, format : TextUi::Format)
    @label.text = text
    @label.default_format = format
    @stack.current_widget = @label
  end

  private def show_result_overlay(value)
    ui = @box.ui
    height = {value.count("\n") + 3, ui.height - 3}.min
    line_max_width = value.each_line.map(&.size).max? || 0
    width = {line_max_width + 2, ui.width}.min

    dialog = TextUi::Dialog.new(ui, "Value")
    dialog.resize(width, height)
    label = TextUi::Label.new(dialog, 1, 1, value)
    label.resize(dialog.width - 2, dialog.height - 2)
    ui.focus(dialog)
    dialog.dismissed.on { ui.focus(@table) }
  end
end
