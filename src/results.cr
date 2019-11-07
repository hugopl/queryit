require "csv"

class Results
  delegate :y=, to: @box
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

  def width=(width)
    @box.width = width
    @table.width = width - 2
  end

  def height=(height)
    @box.height = height
    @table.height = height - 2
  end
end
