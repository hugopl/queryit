module TextUi
  class InputBuffer
    property buffer
    property cursor

    delegate clear, to: buffer

    def initialize(@buffer = "", @cursor = 0)
    end

    def handle_key_input(chr : Char, key : UInt16)
      if key == KEY_SPACE
        chr = ' '
        key = 0
      elsif key == KEY_ENTER
        chr = '\n'
        key = 0
      end

      if key == 0 && chr.ord != 0
        @buffer = @buffer.insert(@cursor, chr)
        @cursor += 1
      elsif (key == KEY_BACKSPACE || key == KEY_BACKSPACE2) && @buffer.size > 0
        @buffer = String.build(@buffer.size) do |buffer|
          buffer << @buffer[0...@cursor - 1]
          buffer << @buffer[@cursor..-1]
        end
        @cursor -= 1
      elsif key == KEY_ARROW_LEFT
        @cursor -= 1
      elsif key == KEY_ARROW_RIGHT
        @cursor += 1
      elsif key == KEY_END
        @cursor = @buffer.size
      elsif key == KEY_HOME
        @cursor = 0
      elsif key == KEY_DELETE && @cursor < @buffer.size
        @buffer = String.build(@buffer.size) do |buffer|
          buffer << @buffer[0...@cursor]
          buffer << @buffer[(@cursor + 1)..-1]
        end
      end

      if @cursor < 0
        @cursor = 0
      elsif @cursor > @buffer.size
        @cursor = @buffer.size
      end
    end
  end
end
