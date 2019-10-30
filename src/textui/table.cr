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
      widths = calculate_column_widths

      x = 0
      widths.each_with_index do |size, i|
        size = width - x if x + size > width
        puts(x, 0, @column_names[i], Color::White | Attr::Bold, limit: size)
        x += size + 1
      end

      y = 1
      @rows.each do |row|
        x = 0
        widths.each_with_index do |size, i|
          size = width - x if x + size > width
          puts(x, y, row[i], Color::Grey, stop_on_lf: true, limit: size)
          x += size + 1
        end
        y += 1
        break if y >= height
      end
    end

    private def calculate_column_widths
      widths = calculate_column_max_widths
      sum = widths.sum + @column_names.size - 1
      return widths if sum <= width

      extra_chars = sum - width
      averages = calculate_column_averages
      averages.each do |(index, avg)|
        next if @column_names[index] == "id"

        extra_chars -= (widths[index] - avg)
        avg += -extra_chars if extra_chars < 0
        widths[index] = avg
        break if extra_chars <= 0
      end

      widths
    end

    private def calculate_column_max_widths
      Array(Int32).new(@column_names.size) do |i|
        max_rows = @rows.empty? ? 0 : @rows.each.map(&.[](i).size).max
        {max_rows, @column_names[i].size}.max
      end
    end

    private def calculate_column_averages
      averages = Array(Array(Int32)).new(@column_names.size) do |i|
        avg = if @rows.empty?
                @column_names.size
              else
                temp = @rows.each.map(&.[](i).size).sum//(@rows.size + 1)
                {@column_names[i].size, temp}.max
              end
        [i, avg]
      end

      averages.sort! { |a, b| b[1] <=> a[1] }
    end
  end
end
