def debug(text : String)
  File.open("/tmp/debug.txt", "a", &.puts(text))
end

def debug(obj)
  File.open("/tmp/debug.txt", "a", &.puts(obj.inspect))
end

module TextUi
  class Ui < Widget
    @focused_widget : Widget?

    def initialize(color_mode = ColorMode::Just256Colors)
      @event = Terminal::Event.new(type: 0, mod: 0, key: 0, ch: 0, w: 0, x: 0, y: 0)
      @shutdown = false
      super(self)

      Terminal.init(color_mode)
    end

    def shutdown!
      @shutdown = true
    end

    def focus(widget : Widget)
      @focused_widget = widget
    end

    def render
    end

    def main_loop
      raise "No key input handled found!" if @on_key_input.nil?

      handle_resize(Terminal.width, Terminal.height)
      e = @event
      loop do
        render_children
        Terminal.present
        Terminal.poll_event(pointerof(e))

        case e.type
        when Terminal::EVENT_KEY then handle_key_input(e.ch.chr, e.key)
        when Terminal::EVENT_MOUSE
        when Terminal::EVENT_RESIZE then handle_resize(e.w, e.x)
        end

        break if @shutdown
      end
      Terminal.shutdown
    end

    def on_resize(proc : (Int32, Int32) ->)
      @on_resize = proc
    end

    def on_key_input(proc : (Char, UInt16) ->)
      @on_key_input = proc
    end

    private def handle_resize(width, height)
      self.width = width
      self.height = height
      Terminal.clear
      invalidate
      callback = @on_resize
      callback.call(width, height) if callback
    end

    def handle_key_input(chr : Char, key : UInt16)
      focused_widget = @focused_widget
      focused_widget.handle_key_input(chr, key) unless focused_widget.nil?

      callback = @on_key_input
      callback.call(chr, key) if callback
    end
  end
end
