module TextUi
  class Table < Widget
    getter column_names
    getter rows

    def initialize(parent, x, y)
      super

      @column_names = [] of String
      @column_widths = [] of Int32
      @rows = [] of Array(String)
      @cursor_x = 0
      @cursor_y = 0
      @viewport_x = 0
      @viewport_y = 0

      @foregroundColor = Color::Grey
    end

    def clear
      @column_names.clear
      @column_widths.clear
      @rows.clear
      invalidate
    end

    # First line is considered the header
    def set_data(rows : Array(Array(String))) : Nil
      @column_names = rows.shift
      @rows = rows
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
      @column_widths = calculate_column_widths if @column_widths.empty?

      render_headers

      # Render table body
      viewport_height = height - 1 # table headers are always show
      has_scrollup = @viewport_y > 0
      has_scrolldown = @rows.size + 1 - @viewport_y > viewport_height

      y = 1
      (height - 1).times do |i|
        row_idx = i + @viewport_y
        break if i >= height || row_idx >= @rows.size
        row = @rows[row_idx]

        x = 0

        @column_widths.size.times do |i|
          col_idx = i + @viewport_x
          break if col_idx >= @column_widths.size

          col_width = @column_widths[col_idx]
          col_width = width - x if x + col_width > width
          color = if focused? && row_idx == @cursor_y && col_idx == @cursor_x
                    foregroundColor | Attr::Reverse
                  else
                    foregroundColor
                  end

          print_line(x, y, row[col_idx], color, width: col_width)
          x += col_width + 1

          break if x >= width
        end

        y += 1
      end
    end

    private def render_headers
      x = 0
      @column_names.size.times do |i|
        col_idx = i + @viewport_x
        break if col_idx >= @column_names.size

        col_width = @column_widths[col_idx]
        col_width = width - x if x + col_width > width
        print_line(x, 0, @column_names[col_idx], Color::White | Attr::Bold, width: col_width)
        x += col_width + 1
        break if x >= width
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

    def handle_key_input(chr : Char, key : UInt16)
      return if @rows.empty?

      super
      case key
      when KEY_ARROW_UP    then @cursor_y -= 1
      when KEY_ARROW_DOWN  then @cursor_y += 1
      when KEY_ARROW_LEFT  then @cursor_x -= 1
      when KEY_ARROW_RIGHT then @cursor_x += 1
      when KEY_ENTER
      end

      if @cursor_x < 0
        @cursor_x = 0
      elsif @cursor_x >= @column_names.size
        @cursor_x = @column_names.size - 1
      end
      if @cursor_y < 0
        @cursor_y = 0
      elsif @cursor_y >= @rows.size
        @cursor_x = @rows.size - 1
      end

      if @cursor_y - @viewport_y >= height - 1
        @viewport_y += 1
      elsif @cursor_y < @viewport_y
        @viewport_y -= 1
      end

      viewport_last_column = 0
      viewport_width = 0
      @column_widths.each(within: @viewport_x..-1) do |col_width|
        viewport_width += col_width
        break if viewport_width >= width

        viewport_last_column += 1
      end

      if @viewport_x < @column_names.size && viewport_width > width && @cursor_x - @viewport_x >= viewport_last_column
        @viewport_x += 1
      elsif @viewport_x != 0 && @cursor_x < @viewport_x
        @viewport_x -= 1
      end

      invalidate
    end
  end
end
