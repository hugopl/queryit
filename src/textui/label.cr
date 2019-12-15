module TextUi
  class Label < Widget
    property text

    def initialize(parent, @text : String = "")
      super(parent)
    end

    def initialize(parent, x, y, @text : String = "")
      super(parent, x, y)
    end

    def text=(@text)
      invalidate
    end

    def render
      erase
      print_lines(0, 0, @text)
    end
  end
end
