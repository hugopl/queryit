module TextUi
  class TextBlock
    property text : String
    delegate size, to: @text

    def initialize(@text : String = "")
    end
  end

  class TextDocument
    getter blocks : Array(TextBlock)

    @blocks = [] of TextBlock
    @filename = ""

    def initialize(contents : String = "")
      self.contents = contents
    end

    def contents=(contents : String) : Nil
      # FIXME: Emit a signal about document changed to reset cursors
      @blocks = contents.lines.map { |line| TextBlock.new(line) }
      @blocks << TextBlock.new if @blocks.empty?
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
      block = TextBlock.new(text)
      @blocks.insert(line + 1, block)
    end

    def remove(line : Int32) : Nil
      @blocks.delete_at(line)
    end
  end
end
