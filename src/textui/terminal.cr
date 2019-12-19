# Wrapper module around termbox to make terminal UIs testable.
module TextUi
  class TerminalError < Exception
  end

  class Terminal
    @@initiated = false

    def self.init(color_mode) : Void
      error = TermboxBindings.tb_init
      if error == TermboxBindings::E_UNSUPPORTED_TERMINAL
        raise TerminalError.new("Terminal is unsupported.")
      elsif error == TermboxBindings::E_FAILED_TO_OPEN_TTY
        raise TerminalError.new("Failed to open terminal.")
      elsif error == TermboxBindings::E_PIPE_TRAP_ERROR
        raise TerminalError.new("Pipe trap error.")
      end

      TermboxBindings.tb_select_output_mode(color_mode)
      @@initiated = true
    end

    def self.shutdown
      return unless @@initiated

      TermboxBindings.tb_shutdown
      @@initiated = false
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

    def self.poll_event(event : Pointer(Event)) : Nil
      TermboxBindings.tb_poll_event(event)
    end

    def self.peek_event(event : Pointer(Event), timeout : Int32) : Bool
      TermboxBindings.tb_peek_event(event, timeout) > 0
    end

    def self.set_cursor(x, y)
      TermboxBindings.tb_set_cursor(x, y)
    end

    def self.change_cell(x : Int32, y : Int32, chr : Char, format : Format)
      TermboxBindings.tb_change_cell(x, y, chr.ord, format.foreground, format.background)
    end
  end
end
