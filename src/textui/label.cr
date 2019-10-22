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

    def cursor
      input = @input
      return 0 if input.nil?

      input.cursor
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
      return if input.nil?

      input.buffer = text
      input.cursor = text.size if input.cursor > text.size
    end

    private def render_cursor
      input = @input
      return if input.nil?

      cursor = input.cursor
      cursor_x = absolute_x
      cursor_y = absolute_y
      idx = 0
      last_idx = -1
      debug("Text: #{@text.inspect}, cursor: #{cursor}")
      loop do
        idx = @text.index('\n', last_idx + 1)
        if idx.nil? || idx >= cursor
          cursor_x += cursor - last_idx - 1
          break
        end
        last_idx = idx
        cursor_y += 1
      end
      Terminal.set_cursor(cursor_x, cursor_y)
    end

    def render
      clear_text(0, 0, @old_text) unless @old_text.empty?
      puts(0, 0, @text)
      render_cursor

      @old_text = ""
    end
  end
end
