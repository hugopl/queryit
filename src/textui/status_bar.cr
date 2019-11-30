module TextUi
  class StatusBar < Widget
    def initialize(parent)
      super(parent, 0, parent.height - 1, parent.width, 1)

      @message = ""
      @message_color = foregroundColor
      @shortcuts = {} of String => String
    end

    def add_shortcut(shortcut, label)
      @shortcuts[shortcut] = label
    end

    def info(message : String)
      @message = message
      @message_color = Color::Blue
      invalidate
    end

    def error(message : String)
      @message = message
      @message_color = Color::Red
      invalidate
    end

    def render
      if !@message.empty?
        print_line(0, 0, @message, @message_color, width: width)
        @message = ""
        invalidate
        return
      end

      step = width//@shortcuts.size

      x = 0
      @shortcuts.each do |shortcut, label|
        print_line(x, 0, shortcut, foregroundColor | Attr::Reverse)
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
