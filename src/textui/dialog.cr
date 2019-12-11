require "cute"

module TextUi
  class Dialog < Box
    Cute.signal dismissed

    @resized_con : Cute::ConnectionHandle = 0
    @focus_changed_con : Cute::ConnectionHandle = 0

    def initialize(parent : Widget, title : String = "")
      super(parent, 0, 0, title)

      @resized_con = ui.resized.on { repositionate(width, height) }
      @focus_changed_con = ui.focus_changed.on do |_old_widget, new_widget|
        dismiss if new_widget != self
      end
    end

    def resize(width, height)
      width = {min_width, width}.max
      super(width, height)

      repositionate(width, height)
    end

    def min_width
      @title.size + 6
    end

    private def repositionate(width, height)
      move((parent.width - width) // 2, (parent.height - height) // 2)
    end

    def handle_key_input(chr : Char, key : UInt16)
      dismiss
    end

    def dismiss
      destroy
      parent.invalidate
      ui.resized.disconnect(@resized_con)
      ui.focus_changed.disconnect(@focus_changed_con)
      dismissed.emit
      dismissed.disconnect
    end
  end
end
