module TextUi
  class TextEditor < Widget
    getter cursors : Array(TextCursor)
    getter? show_line_numbers : Bool
    property? wrap_lines : Bool
    property viewport_x : Int32

    delegate open, to: @document
    delegate save, to: @document

    def initialize(parent, x, y, width, height)
      super
      @document = TextDocument.new
      @cursors = [TextCursor.new(@document)]
      # Appearance
      @wrap_lines = false
      @show_line_numbers = false
      # Viewport
      @viewport_x = 0
    end

    def show_line_numbers=(value : Bool) : Nil
      return if value == @show_line_numbers

      @show_line_numbers = value
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
      # Dumb implementation for now, since we don't have word-wrap or viewport
      cursor = @cursors.first
      x = cursor.col + calc_border_width
      y = cursor.line
      x = y = -1 if x >= width || y >= height
      set_cursor(x, y)
    end

    def render
      render_cursors if focused?

      border_width = calc_border_width
      line_tag_format = @show_line_numbers ? "%#{border_width - 1}d│" : ""

      y = 0
      @document.blocks.each_with_index do |block, line|
        if @show_line_numbers
          line_tag = line_tag_format % (line + 1)
          print_line(0, y, line_tag, Color::Grey2)
        end
        print_line(border_width, y, block.text, width: width - border_width)
        y += 1

        break if y >= height
      end
      y.upto(height - 1) do |yy|
        print_line(0, yy, "~", width: width)
      end
    end

    private def calc_border_width
      @show_line_numbers ? @document.blocks.size.to_s.size + 1 : 0
    end

    def handle_key_input(chr : Char, key : UInt16)
      @cursors.each do |cursor|
        # destroy_cursor(cursor)
        cursor.handle_key_input(chr, key)
      end

      invalidate
    end
  end
end
