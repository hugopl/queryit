module TextUi
  class TextCursor
    getter line : Int32
    getter col : Int32
    property? insert_mode : Bool
    getter? valid : Bool

    def initialize(@document : TextDocument)
      @line = 0
      @col = 0
      @last_col = 0
      @insert_mode = false
      @valid = true
    end

    def invalidate
      @valid = false
    end

    def move(@line = 0, @col = 0)
      @last_col = 0
    end

    def current_block
      @document.blocks[@line]
    end

    def handle_key_input(chr : Char, key : UInt16) : Nil
      return unless valid?

      block = current_block

      case key
      when KEY_INSERT     then @insert_mode = !@insert_mode
      when KEY_ARROW_UP   then @line -= 1
      when KEY_ARROW_DOWN then @line += 1
      when KEY_ARROW_LEFT
        @col -= 1
        if @col < 0 && @line > 0
          @line -= 1
          @col = @document.blocks[@line].size
        end
      when KEY_ARROW_RIGHT
        @col += 1
        if @col > block.size && @line < @document.blocks.size - 1
          @line += 1
          @col = 0
        end
      when KEY_END  then @col = block.size
      when KEY_HOME then @col = 0
      else
        handle_text_modification(chr, key, block)
      end

      @last_col = @col if key != KEY_ARROW_UP && key != KEY_ARROW_DOWN && key != KEY_INSERT

      @line = @line.clamp(0, @document.blocks.size - 1)
      @col = {@col, @last_col}.max.clamp(0, current_block.size)
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
        if insert_mode? && @col < buffer.size
          buffer = buffer.sub(@col, chr)
        else
          buffer = buffer.insert(@col, chr)
        end
        @col += 1
      elsif key == KEY_BACKSPACE || key == KEY_BACKSPACE2
        if @col == 0 && @line > 0
          previous_block = @document.blocks[@line - 1]
          @col = previous_block.size
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
