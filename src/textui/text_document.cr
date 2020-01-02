module TextUi
  class TextBlock
    # Class is used to associate custom state with TextBlocks
    class State
      property? changed : Bool = false

      def changed!
        @changed = true
      end
    end

    getter text : String
    getter formats : Array(Format)
    property! previous_block : TextBlock?
    property! next_block : TextBlock?
    property state : State
    delegate size, to: @text

    @formats = [] of Format
    @state = State.new

    def initialize(@document : TextDocument, @text = "", @previous_block = nil, @next_block = nil)
      reset_format
    end

    def text=(@text : String)
      @document.highlight_block(self)
    end

    def reset_format
      @formats = Array(Format).new(@text.size, Format::DEFAULT)
    end

    def apply_format(start : Int32, finish : Int32, format : Format)
      (start...finish).each do |i|
        @formats[i] = format
      end
    end

    def inspect(io : IO)
      io << "<Blk #{@text.inspect} #{@formats.inspect}>"
    end
  end

  class TextDocument
    getter blocks : Array(TextBlock)

    @blocks = [] of TextBlock
    @filename = ""
    @syntax_highlighter = PlainTextSyntaxHighlighter.new

    def initialize
      @blocks = [TextBlock.new(self)]
    end

    def contents=(contents : String) : Nil
      previous_block = nil
      @blocks = contents.lines.map do |line|
        block = TextBlock.new(self, line, previous_block)
        previous_block.try(&.next_block = block)
        previous_block = block
      end
      @blocks << TextBlock.new(self) if @blocks.empty?
      reset_syntaxhighlighting
    end

    def open(@filename : String)
      self.contents = File.read(@filename)
    end

    def save(io : IO)
      @blocks.each do |block|
        io.write(block.text.unsafe_byte_slice(0))
        io.write_byte('\n'.ord.to_u8)
      end
    end

    def contents
      @blocks.map(&.text).join("\n")
    end

    def insert(line : Int32, text : String) : Nil
      previous_line = line - 1
      block = TextBlock.new(self, text, block?(previous_line), block?(line))

      block?(previous_line).try(&.next_block = block)
      block?(line).try(&.previous_block = block)
      @blocks.insert(line, block)

      highlight_block(block)
    end

    def remove(line : Int32) : Nil
      previous_block = block?(line - 1)
      next_block = block?(line + 1)
      previous_block.try(&.next_block = next_block)
      next_block.try(&.previous_block = previous_block)

      @blocks.delete_at(line)
    end

    def block?(line) : TextBlock?
      line < 0 ? nil : @blocks[line]?
    end

    def syntax_highlighter=(@syntax_highlighter : SyntaxHighlighter)
      reset_syntaxhighlighting
    end

    def highlight_block(block)
      block.state.changed = false
      block.reset_format
      @syntax_highlighter.highlight_block(block)
      highlight_block(block.next_block) if block.state.changed? && block.next_block?
    end

    def reset_syntaxhighlighting
      @blocks.each do |block|
        @syntax_highlighter.highlight_block(block)
      end
    end
  end
end
