require "csv"

class ResultsControl
  delegate clear, to: @table
  delegate set_data, to: @table

  def initialize(ui : TextUi::Ui)
    @box = TextUi::Box.new(ui, "Results", "F4")
    @table = TextUi::Table.new(@box, 1, 1)
    ui.add_focus_shortcut(TextUi::KEY_F4, @table)
  end

  def empty?
    @table.rows.empty?
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
  end
end
