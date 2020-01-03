module TextUi
  class TextBlock
    getter text : String
    getter formats : Array(Format)
    delegate size, to: @text

    @formats = [] of Format

    def initialize(@document : TextDocument, @text = "")
      reset_format
    end

    def text=(@text : String)
      reset_format
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
    delegate highlight_block, to: @syntax_highlighter

    @blocks = [] of TextBlock
    @filename = ""
    @syntax_highlighter = PlainTextSyntaxHighlighter.new

    def initialize
      @blocks = [TextBlock.new(self)]
    end

    def contents=(contents : String) : Nil
      @blocks = contents.lines.map { |line| TextBlock.new(self, line) }
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
      block = TextBlock.new(self, text)
      @blocks.insert(line, block)

      highlight_block(block)
    end

    def remove(line : Int32) : Nil
      @blocks.delete_at(line)
    end

    def syntax_highlighter=(@syntax_highlighter : SyntaxHighlighter)
      reset_syntaxhighlighting
    end

    def reset_syntaxhighlighting
      @blocks.each do |block|
        highlight_block(block)
      end
    end
  end
end
