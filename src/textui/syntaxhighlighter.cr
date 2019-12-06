module TextUi
  abstract class SyntaxHighlighter
    abstract def highlight_block(block : TextBlock)
  end

  class PlainTextSyntaxHighlighter < SyntaxHighlighter
    def highlight_block(_block : TextBlock)
    end
  end
end
