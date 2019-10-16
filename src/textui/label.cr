module TextUi
  class Label < Widget
    property text
    getter accept_input

    @input : InputBuffer?

    def initialize(parent, x, y, @text : String)
      super(parent, x, y, @text.size, 1) # FIXME count linefeeds to specify real size
      @old_text = ""
      @accept_input = false
    end

    def accept_input
      @input ||= TextUi::InputBuffer.new(@text)
    end

    def cursor=(cursor)
      input = @input
      return if input.nil?
      return if cursor < 0 || cursor > @text.size

      input.cursor = cursor
    end

    def handle_key_input(chr : Char, key : UInt16)
      input = @input
      return if input.nil?
      input.handle_key_input(chr, key)
      self.text = input.buffer
    end

    def text=(text)
      invalidate
      @old_text = @text
      @text = text

      input = @input
      input.buffer = text unless input.nil?
    end

    private def render_cursor
      input = @input
      return if input.nil?

      cursor = input.cursor
      i = 0
      cursor_x = @parent.x + x
      cursor_y = @parent.y + y
      origin_x = cursor_x
      limit_x = @width + origin_x - 1
      each_char_pos(0, 0, @text) do |x, y, chr|
        i += 1
        if i == cursor
          if chr == '\n'
            cursor_x = origin_x
            cursor_y += 1
          else
            cursor_x = x + 1
            cursor_y = y
          end
          if cursor_x > limit_x
            cursor_x = origin_x
            cursor_y += 1
          end
          break
        end
      end
      TermboxBindings.tb_set_cursor(cursor_x, cursor_y)
    end

    def render
      clear_text(0, 0, @old_text) unless @old_text.empty?
      puts(0, 0, @text)
      render_cursor

      @old_text = ""
    end
  end
end
