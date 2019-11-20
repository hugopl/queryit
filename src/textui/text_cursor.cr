module TextUi
  class TextCursor
    getter line : Int32
    getter col : Int32

    def initialize(@document : TextDocument)
      @line = 0
      @col = 0
    end

    def move(@line = 0, @col = 0)
    end

    def current_block
      @document.blocks[@line]
    end

    def handle_key_input(chr : Char, key : UInt16) : Nil
      block = current_block

      case key
      when KEY_ARROW_UP    then @line -= 1
      when KEY_ARROW_DOWN  then @line += 1
      when KEY_ARROW_LEFT  then @col -= 1
      when KEY_ARROW_RIGHT then @col += 1
      when KEY_END         then @col = block.size
      when KEY_HOME        then @col = 0
      else
        handle_text_modification(chr, key, block)
      end

      @line -= 1 if @col < 0
      @line = @line.clamp(0, @document.blocks.size - 1)
      @col = @col.clamp(0, current_block.size)
    end

    def handle_text_modification(chr, key, block) : Nil
      buffer = block.text

      if key == KEY_SPACE
        chr = ' '
        key = 0
      elsif key == KEY_ENTER
        new_line = block.text[@col..-1]
        block.text = block.text[0...col]
        @document.insert(@line, new_line)
        @line += 1
        @col = 0
        return
      end

      if key == 0 && chr.ord != 0
        buffer = buffer.insert(@col, chr)
        @col += 1
      elsif key == KEY_BACKSPACE || key == KEY_BACKSPACE2
        if @col == 0 && @line > 0
          previous_block = @document.blocks[@line - 1]
          previous_block.text = previous_block.text + block.text
          @document.remove(@line)
          @line -= 1
        elsif @col != 0 && buffer.size > 0
          buffer = String.build(buffer.size) do |str|
            str << buffer[0...@col - 1]
            str << buffer[@col..-1]
          end
          @col -= 1
        end
      elsif key == KEY_DELETE
        if @col == buffer.size && @document.blocks.size > @line + 1
          next_line = @line + 1
          next_block = @document.blocks[next_line]
          buffer = buffer + next_block.text
          @document.remove(next_line)
        elsif @col < buffer.size
          buffer = String.build(buffer.size) do |str|
            str << buffer[0...@col]
            str << buffer[(@col + 1)..-1]
          end
        end
      end
      block.text = buffer
    end
  end
end
