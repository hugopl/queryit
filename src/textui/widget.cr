module TextUi
  abstract class Widget
    property x
    property y
    property width
    property height
    property foregroundColor
    property backgroundColor
    setter focused : Bool
    setter key_input_handler : Proc(Char, UInt16, Nil)?

    delegate :<<, to: @children
    getter children

    def initialize(@parent : Widget, @x = 0, @y = 0, @width = 0, @height = 0)
      @foregroundColor = Color::Silver
      @backgroundColor = Color::Black
      @children = [] of Widget
      @focused = false
      @render_pending = true
      @parent << self if @parent != self
    end

    def render_pending?
      @render_pending
    end

    def clear_text(x, y, text, foreground = @foregroundColor, background = @backgroundColor, stop_on_lf = false)
      each_char_pos(x, y, text) do |xx, yy, chr|
        if chr == '\n'
          break if stop_on_lf
          next
        end
        Terminal.change_cell(xx, yy, ' ', foreground, background)
      end
    end

    def clear_text(x, y, n : Int32, foreground = @foregroundColor, background = @backgroundColor, stop_on_lf = false)
      x += absolute_x
      y += absolute_y
      n.times do |i|
        Terminal.change_cell(x + i, y, ' ', foreground, background)
      end
    end

    def focused?
      @focused
    end

    def set_cursor(x, y)
      Terminal.set_cursor(absolute_x + x, absolute_y + y)
    end

    def absolute_x
      @parent.absolute_x + @x
    end

    def absolute_y
      @parent.absolute_y + @y
    end

    def absolute_width
      @parent.absolute_width + @width
    end

    def absolute_height
      @parent.absolute_height + @height
    end

    def puts(x, y, text : String, foreground = @foregroundColor, background = @backgroundColor, stop_on_lf = false, limit = 0)
      count = 0
      limit = 0 if text.size <= limit # Turn off limit if the string fits
      each_char_pos(x, y, text) do |xx, yy, chr|
        count += 1
        limit_reached = count >= limit if limit != 0
        if limit_reached
          chr = '…'
        elsif chr == '\n'
          next unless stop_on_lf

          chr = '↵'
          limit_reached = true
        elsif chr == '\r'
          chr = '␍'
        end
        Terminal.change_cell(xx, yy, chr, foreground, background)
        break if limit_reached
      end
    end

    def each_char_pos(x, y, text : String)
      origin_x = x + absolute_x
      x_limit = @width + origin_x - 1
      x = origin_x
      y += absolute_y
      text.each_char do |chr|
        yield(x, y, chr)
        if chr == '\n'
          y += 1
          x = origin_x
        else
          if x == x_limit
            x = origin_x
            y += 1
          else
            x += 1
          end
        end
      end
    end

    def putc(x : Int32, y : Int32, chr : Char, foreground = @foregroundColor, background = @backgroundColor)
      x += absolute_x
      y += absolute_y
      Terminal.change_cell(x, y, chr, foreground, background)
    end

    protected def render_children
      @children.each do |child|
        child.render if child.render_pending?
        child.render_children
      end
      @render_pending = false
    end

    abstract def render

    def render_cursor
    end

    def handle_key_input(chr : Char, key : UInt16)
      callback = @key_input_handler
      callback.call(chr, key) if callback
    end

    def invalidate
      @render_pending = true
      @children.each(&.invalidate)
    end
  end
end
