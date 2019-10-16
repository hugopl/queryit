module TextUi
  class Table < Widget
    property column_names
    property rows

    def initialize(parent, x, y)
      super

      @column_names = [] of String
      @rows = [] of Array(String)
    end

    def clear
      @column_names.clear
      @rows.clear
      invalidate
    end

    def clear_table_display
      width.times do |x|
        height.times do |y|
          putc(x, y, ' ', Color::White, Color::Black)
        end
      end
    end

    def render
      clear_table_display
      debug("table render")
      debug(column_names)
      debug(rows)
      column_sizes = calculate_column_sizes
      debug(column_sizes)
      x = 0
      column_sizes.each_with_index do |size, i|
        puts(x, 0, @column_names[i], Color::White | Attr::Bold)
        x += size + 1
      end

      y = 1
      @rows.each do |row|
        x = 0
        column_sizes.each_with_index do |size, i|
          puts(x, y, row[i], Color::Grey, stop_on_lf: true, limit: column_sizes[i])
          x += size + 1
        end
        y += 1
        break if y >= height
      end
    end

    private def calculate_column_sizes
      sizes = Array(Int32).new(@column_names.size) do |i|
        calculate_column_size(i)
      end
      sum = sizes.sum + @column_names.size - 1
      sizes
    end

    private def calculate_column_size(i)
      max_rows = @rows.empty? ? 0 : @rows.each.map(&.[](i).size).max
      {max_rows, @column_names[i].size}.max
    end

    private def column_densities
      Array(Int32).new(@column_names.size) do |i|
      end
    end
  end
end
