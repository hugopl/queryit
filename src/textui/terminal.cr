# Wrapper module around termbox to make terminal UIs testable.
module TextUi
  class Terminal
    def self.init(color_mode) : Void
      error = TermboxBindings.tb_init
      if error == TermboxBindings::E_UNSUPPORTED_TERMINAL
        raise "Terminal is unsupported."
      elsif error == TermboxBindings::E_FAILED_TO_OPEN_TTY
        raise "Failed to open terminal."
      elsif error == TermboxBindings::E_PIPE_TRAP_ERROR
        raise "Pipe trap error."
      end

      TermboxBindings.tb_select_output_mode(color_mode)
    end

    def self.shutdown
      TermboxBindings.tb_shutdown
    end

    def self.width
      TermboxBindings.tb_width
    end

    def self.height
      TermboxBindings.tb_height
    end

    def self.present
      TermboxBindings.tb_present
    end

    def self.clear
      TermboxBindings.tb_clear
    end

    alias Event = TermboxBindings::Event

    EVENT_KEY    = 1
    EVENT_RESIZE = 2
    EVENT_MOUSE  = 3

    def self.poll_event(event : Pointer(Event))
      TermboxBindings.tb_poll_event(event)
    end

    def self.set_cursor(x, y)
      TermboxBindings.tb_set_cursor(x, y)
    end

    def self.change_cell(x : Int32, y : Int32, chr : Char, foreground, background)
      TermboxBindings.tb_change_cell(x, y, chr.ord, foreground, background)
    end
  end
end
