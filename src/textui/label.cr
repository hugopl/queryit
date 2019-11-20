module TextUi
  class Label < Widget
    property text

    def initialize(parent, x, y, @text : String)
      super(parent, x, y, @text.size, 1) # FIXME count linefeeds to specify real size
      @old_text = ""
    end

    def text=(text)
      invalidate
      @old_text = @text
      @text = text
    end

    def render
      clear_text(0, 0, @old_text) unless @old_text.empty?
      print_lines(0, 0, @text)

      @old_text = ""
    end
  end
end
