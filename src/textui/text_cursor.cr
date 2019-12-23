module TextUi
  class TextCursor
    include Comparable(TextCursor)

    getter line : Int32
    getter col : Int32
    property col_hint : Int32
    property? insert_mode : Bool
    getter? valid : Bool

    def initialize(@document : TextDocument)
      @line = 0
      @col = 0
      @col_hint = 0
      @insert_mode = false
      @valid = true
    end

    def invalidate
      @valid = false
    end

    def move(line, col) : Nil
      self.line = line
      self.col = col
    end

    def line=(line)
      @line = line.clamp(0, @document.blocks.size - 1)
    end

    def col=(col)
      @col = col.clamp(0, current_block.size)
    end

    def <=>(other : TextCursor)
      value = @line <=> other.line
      value.zero? ? @col <=> other.col : 0
    end

    def current_block
      @document.blocks[@line]
    end

    protected def on_key_event(event : KeyEvent)
      return unless valid?

      if event.key == KEY_INSERT
        @insert_mode = !@insert_mode
      else
        handle_text_modification(event.char, event.key, current_block)
      end
    end

    def handle_text_modification(chr, key, block) : Nil
      buffer = block.text

      if key == KEY_SPACE
        chr = ' '
        key = 0
      elsif key == KEY_ENTER
        new_line = block.text[@col..-1]
        block.text = block.text[0...@col]
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
      @col_hint = @col
      move(@line, @col) # Just to fix out of range values
    end
  end
end
