module TextUi
  class ShortcutBar < Widget
    @shortcuts : Hash(String, String)

    def initialize(parent)
      super(parent, 0, parent.height - 1, parent.width, 1)

      @shortcuts = {} of String => String
    end

    def add_shortcut(shortcut, label)
      @shortcuts[shortcut] = label
    end

    def render
      step = width//@shortcuts.size

      debug("width: #{width}")
      debug("step: #{step}")
      x = 0
      @shortcuts.each do |shortcut, label|
        print_line(x, 0, shortcut, foregroundColor | Attr::Reverse)
        x += shortcut.size
        putc(x, 0, ' ')
        x += 1
        remain = step - shortcut.size - 1
        debug("#{shortcut} - #{label}")
        debug("#{remain} = #{step} - #{shortcut.size} - 1 - #{label.size}")
        print_line(x, 0, label, width: remain)
        x += remain
      end
    end
  end
end
