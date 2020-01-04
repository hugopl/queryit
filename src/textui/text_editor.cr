module TextUi
  class TextEditor < Widget
    getter document : TextDocument
    getter cursors : Array(TextCursor)
    getter? show_line_numbers : Bool
    getter? word_wrap : Bool
    # Colors
    property border_color : Format

    delegate open, to: @document
    delegate save, to: @document
    delegate :syntax_highlighter=, to: @document

    Cute.signal key_typed(event : KeyEvent)

    def initialize(parent, x, y, width, height)
      super
      @document = TextDocument.new
      @cursors = [TextCursor.new(@document)]
      # Appearance
      @word_wrap = false
      @show_line_numbers = false
      @border_color = Format.new(Color::Grey2)
      # Rendering
      @block_heights = [] of Int32
      @viewport = 0
    end

    def invalidate
      super
      @block_heights = [] of Int32
    end

    def show_line_numbers=(value : Bool) : Nil
      return if value == @show_line_numbers

      @show_line_numbers = value
      invalidate
    end

    def word_wrap=(value : Bool) : Nil
      return if value == @word_wrap

      @word_wrap = value
      invalidate
    end

    def text=(text) : Nil
      @document.contents = text

      @cursors.first.move(0, 0)
      @cursors.delete_at(1..-1).each(&.invalidate)
      invalidate
    end

    def text
      @document.contents
    end

    def create_cursor(x = 0, y = 0) : TextCursor
      cursor = TextCursor.new(@document)
      cursor.move(x, y)
      @cursors << cursor
      cursor
    end

    def destroy_cursor(cursor) : Nil
      @cursors.delete(cursor)
    end

    def cursor
      @cursors.first
    end

    def render_cursors
      # Just one cursor for now... later I need a ugly workaround to fake multiple cursors
      cursor = @cursors.first

      x, y = map_line_col_to_viewport(cursor.line, cursor.col)
      y -= @viewport

      x = y = -1 if x >= width || y >= height
      set_cursor(x, y)
    end

    private def map_line_col_to_viewport(line, col)
      border_width = calc_border_width
      return [col + border_width, line] unless @word_wrap

      y = 0
      block_heights.each_with_index do |height, i|
        break if i >= line
        y += height
      end
      width_available = width - border_width
      text = @document.blocks[line].text

      x = col
      if text.size > width_available
        y -= 1
        offset = 0
        while offset <= col && offset < text.size
          count = count_chars_before_word_wrap(text, offset, width_available)
          x = col - offset
          offset += count
          y += 1
        end
      end

      [x + border_width, y]
    end

    private def map_viewport_to_line_col(x, y)
      line = 0
      y_acc = 0

      block_heights.each do |height|
        break if y_acc + height > y
        y_acc += height
        line += 1
      end

      return [-1, -1] if line >= @document.blocks.size

      text = @document.blocks[line].text
      border_width = calc_border_width
      width_available = width - border_width

      offset = 0
      while y_acc != y && offset < text.size
        count = count_chars_before_word_wrap(text, offset, width_available)
        offset += count
        y_acc += 1
      end

      col = offset + x - border_width
      [line, col]
    end

    # FIXME: We should store the sum of block heights to let algorithms using this to be O(1) instead of O(n).
    private def block_heights : Array(Int32)
      return @block_heights unless @block_heights.empty?

      width_available = width - calc_border_width
      @block_heights = @document.blocks.map do |block|
        text_size = block.text.size
        if text_size <= width_available
          1
        else
          n = 0
          offset = 0
          while offset < text_size
            offset += count_chars_before_word_wrap(text, offset, width_available)
            n += 1
          end
          n
        end
      end
      @block_heights
    end

    def render
      adjust_viewport
      render_cursors if focused?

      border_width = calc_border_width
      line_tag_format = @show_line_numbers ? "%#{border_width - 1}d│" : ""
      width_available = width - border_width
      line_tag = ""

      start_block, offset = map_viewport_to_line_col(border_width, @viewport)
      y = 0
      start_block.upto(@document.blocks.size - 1) do |line|
        block = @document.blocks[line]
        text = block.text
        formats = block.formats

        # line number printing
        if @show_line_numbers
          line_tag = line_tag_format % (line + 1)
          print_line(0, y, line_tag, @border_color)
        end

        # Word wrap
        if @word_wrap && text.size > width_available
          line_tag = "#{" " * (border_width - 1)}│" if @show_line_numbers
          while y < height
            print_line(0, y, line_tag, @border_color) if @show_line_numbers && !offset.zero?
            count = count_chars_before_word_wrap(text, offset, width_available)

            print_line(border_width, y, text, formats, width: width_available, ellipsis: false, offset: offset, count: count)
            offset += count
            break if offset >= text.size

            y += 1
          end
          offset = 0
        else
          # Peace of cake of word wrap disabled
          print_line(border_width, y, text, formats, width: width_available)
        end
        y += 1

        break if y >= height
      end
      y.upto(height - 1) do |yy|
        print_line(0, yy, "~", width: width)
      end
    end

    # Starting from offset, count how many chars we should print before word wrap in a space of _width_ size
    private def count_chars_before_word_wrap(text, offset, width) : Int32
      max_offset = offset + width
      # If the next character after editor border is a whitespace, we break text here
      return width if text.size > max_offset && text[max_offset].whitespace?

      if max_offset >= text.size # We have space enough for the text.
        return text.size - offset
      else # else... we look for a white space
        max_offset.downto(offset) do |idx|
          return idx - offset + 1 if text[idx].whitespace?
        end
      end
      width # if we can't find one, just cut the text
    end

    private def calc_border_width
      @show_line_numbers ? @document.blocks.size.to_s.size + 1 : 0
    end

    private def is_cursor_movement?(key) : Bool
      case key
      when KEY_HOME, KEY_END,
           KEY_ARROW_UP, KEY_ARROW_DOWN,
           KEY_ARROW_LEFT, KEY_ARROW_RIGHT,
           KEY_PGUP, KEY_PGDN then true
      else
        false
      end
    end

    protected def on_key_event(event : KeyEvent)
      return if event.alt?

      if is_cursor_movement?(event.key)
        @cursors.each { |cursor| handle_cursor_movement(cursor, event.key) }
      else
        @cursors.each &.on_key_event(event)
      end

      key_typed.emit(event)
      invalidate
    end

    private def handle_cursor_movement(cursor, key)
      return unless cursor.valid?

      line = cursor.line
      col = cursor.col
      block = cursor.current_block

      case key
      when KEY_ARROW_LEFT
        col -= 1
        if col < 0 && line > 0
          line -= 1
          col = @document.blocks[line].size
        end
      when KEY_ARROW_RIGHT
        col += 1
        if col > block.size && line < @document.blocks.size - 1
          line += 1
          col = 0
        end
      when KEY_END  then col = block.size
      when KEY_HOME then col = 0
      when KEY_ARROW_UP, KEY_ARROW_DOWN, KEY_PGUP, KEY_PGDN
        handle_line_change(cursor, key)
        return
      end
      cursor.col_hint = col
      cursor.move(line, col)
    end

    private def line_increment_by_key(key)
      case key
      when KEY_ARROW_UP   then -1
      when KEY_ARROW_DOWN then 1
      when KEY_PGUP       then -height
      when KEY_PGDN       then height
      else
        0
      end
    end

    private def handle_line_change(cursor, key) : Nil
      x, y = map_line_col_to_viewport(cursor.line, cursor.col)
      y += line_increment_by_key(key)
      y = y.clamp(0, block_heights.sum - 1)

      line, col = map_viewport_to_line_col(x, y)
      return if line < 0

      cursor.line = line

      border_width = calc_border_width
      width_available = width - border_width
      col = {col, cursor.col_hint}.max if cursor.current_block.size < width_available
      cursor.move(line, col)
    end

    private def adjust_viewport
      max_height = block_heights.sum
      if max_height <= height
        @viewport = 0
        return
      end

      min_cursor = cursors.min
      max_cursor = cursors.max
      min_y = map_line_col_to_viewport(min_cursor.line, min_cursor.col)[1]
      max_y = map_line_col_to_viewport(max_cursor.line, max_cursor.col)[1]

      if min_y < @viewport
        @viewport = min_y
      elsif max_y >= @viewport + height
        @viewport = max_y - height + 1
      end
      @viewport = @viewport.clamp(0, max_height - 1)
    end
  end
end
