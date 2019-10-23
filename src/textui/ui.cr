def debug(text : String)
  File.open("/tmp/debug.txt", "a", &.puts(text))
end

def debug(floats : Array(Float64))
  debug(floats.map(&.humanize))
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
      @shortcuts = Hash(Int32, Widget).new
      super(self)

      Terminal.init(color_mode)
    end

    def shutdown!
      @shutdown = true
    end

    def focus(widget : Widget)
      @focused_widget = widget
    end

    def add_focus_shortcut(key : Int32, widget : Widget)
      @shortcuts[key] = widget
    end

    def absolute_x
      0
    end

    def absolute_y
      0
    end

    def absolute_width
      width
    end

    def absolute_height
      height
    end

    def render
      render_children
    end

    def main_loop
      handle_resize(Terminal.width, Terminal.height)
      e = @event
      loop do
        render_children
        Terminal.present
        Terminal.poll_event(pointerof(e))

        case e.type
        when Terminal::EVENT_KEY then handle_key_event(e.ch.chr, e.key)
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

    private def handle_resize(width, height)
      self.width = width
      self.height = height
      Terminal.clear
      invalidate
      callback = @on_resize
      callback.call(width, height) if callback
    end

    def handle_key_event(chr : Char, key : UInt16)
      widget = @shortcuts[key]?
      if widget
        focus(widget)
        return
      end

      widget = @focused_widget
      widget.handle_key_input(chr, key) if widget
      handle_key_input(chr, key) # Always call the main key input handler
    end

    {% if !flag?(:release) %}
      def handle_key_input(chr : Char, key : UInt16)
        raise "No key input handler defined for Ui object" if @key_input_handler.nil?
        super
      end
    {% end %}
  end
end
