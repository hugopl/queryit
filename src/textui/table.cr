require "cute"

module TextUi
  class Table < Widget
    getter column_names
    getter rows
    property cursor_x
    property cursor_y

    property header_format : Format
    property highlight_format : Format

    Cute.signal enter_pressed(value : String)

    @column_names = [] of String
    @column_widths = [] of Int32
    @rows = [] of Array(String)
    @cursor_x = 0
    @cursor_y = 0

    @viewport_x = 0..0
    @viewport_y = 0

    default_format = Format.new(Color::Grey)
    @header_format = Format.new(Color::White, bold: true)
    @highlight_format = Format.new(Color::Silver).reverse

    def initialize(parent)
      super
    end

    def initialize(parent, x, y)
      super
    end

    def clear
      @column_names.clear
      @column_widths.clear
      @rows.clear
      invalidate
    end

    def width=(value)
      super
      calc_viewport_x
    end

    # First line is considered the header
    def set_data(rows : Array(Array(String))) : Nil
      @column_names = rows.shift
      @rows = rows

      @cursor_x = 0
      @cursor_y = 0
      @viewport_y = 0
      calc_viewport_x
    end

    def render
      erase
      return if rows.empty?

      @column_widths = calculate_column_widths if @column_widths.empty?

      render_headers

      # Render table body
      y = 1
      last_row = @viewport_y + height > @rows.size ? @rows.size : @viewport_y + height - 1
      last_row -= 1
      @viewport_y.upto(last_row) do |row_idx|
        row = @rows[row_idx]
        highlight_at = row_idx == @cursor_y ? @cursor_x : -1
        render_row(row, y, default_format, highlight_at)
        y += 1
      end
    end

    private def render_row(row, y, row_format : Format, highlight_at = -1)
      abs_x = 0 # X in table coordinates, subtract from viewport to get widget coordinates
      @column_widths.each_with_index do |col_width, col_idx|
        next_abs_x = abs_x + col_width + 1
        # Skip out of screen entries
        if abs_x >= @viewport_x.end
          break
        elsif next_abs_x < @viewport_x.begin
          abs_x = next_abs_x
          next
        end

        format = col_idx == highlight_at ? @highlight_format : row_format
        content = row[col_idx]
        x = abs_x - @viewport_x.begin

        if abs_x < @viewport_x.begin && abs_x + col_width <= @viewport_x.end && x.abs < content.size # half leftmost column
          print_char(0, y, '…', format)
          print_line(1, y, content.byte_slice(1 + x.abs), format, width: col_width) # FIXME: Avoid the string copy
        elsif abs_x >= @viewport_x.begin && abs_x + col_width <= @viewport_x.end    # all good
          print_line(x, y, content, format, width: col_width)
        elsif abs_x > @viewport_x.begin && next_abs_x > @viewport_x.end # half rightmost column
          col_width = width - x
          print_line(x, y, content, format, width: col_width)
        end
        abs_x = next_abs_x
      end
    end

    private def render_headers
      render_row(@column_names, 0, @header_format)
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

    protected def on_key_event(event : KeyEvent)
      return if @rows.empty? || @column_widths.empty?

      super
      case event.key
      when KEY_ARROW_UP    then @cursor_y -= 1
      when KEY_ARROW_DOWN  then @cursor_y += 1
      when KEY_ARROW_LEFT  then @cursor_x -= 1
      when KEY_ARROW_RIGHT then @cursor_x += 1
      when KEY_ENTER
        enter_pressed.emit(@rows[@cursor_y][@cursor_x])
        return
      end

      @cursor_x = @cursor_x.clamp(0, @column_names.size - 1)
      @cursor_y = @cursor_y.clamp(0, @rows.size - 1)

      if @cursor_y - @viewport_y >= height - 1
        @viewport_y += 1
      elsif @cursor_y < @viewport_y
        @viewport_y -= 1
      end

      calc_viewport_x

      invalidate
    end

    private def calc_viewport_x
      cursor_x_range = calc_cursor_x_range

      if cursor_x_range.begin <= @viewport_x.begin
        @viewport_x = cursor_x_range.begin..(cursor_x_range.begin + width)
      elsif cursor_x_range.end > @viewport_x.end
        @viewport_x = (cursor_x_range.end - width)..cursor_x_range.end
      end
    end

    private def calc_cursor_x_range : Range
      x = 0
      @column_widths.each_with_index do |col_width, i|
        x += col_width
        return ((x - col_width)..x) if i == @cursor_x

        x += 1
      end

      0..0
    end
  end
end
