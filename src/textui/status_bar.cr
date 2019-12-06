module TextUi
  class StatusBar < Widget
    property shortcut_format : Format

    def initialize(parent)
      super(parent, 0, parent.height - 1, parent.width, 1)

      @message = ""
      @message_format = default_format
      @shortcut_format = default_format.reverse
      @shortcuts = {} of String => String
    end

    def add_shortcut(shortcut, label)
      @shortcuts[shortcut] = label
    end

    def info(message : String)
      @message = message
      @message_format = Format.new(Color::Blue)
      invalidate
    end

    def error(message : String)
      @message = message
      @message_format = Format.new(Color::Red)
      invalidate
    end

    def render
      if !@message.empty?
        print_line(0, 0, @message, @message_format, width: width)
        @message = ""
        invalidate
        return
      end

      step = width//@shortcuts.size

      x = 0
      @shortcuts.each do |shortcut, label|
        print_line(x, 0, shortcut, @shortcut_format)
        x += shortcut.size
        print_char(x, 0, ' ')
        x += 1
        remain = step - shortcut.size - 1
        print_line(x, 0, label, width: remain)
        x += remain
      end
    end
  end
end
