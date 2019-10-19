module TextUi
  abstract class Widget
    property x
    property y
    property width
    property height
    property foregroundColor
    property backgroundColor

    delegate :<<, to: @children
    getter children

    def initialize(@parent : Widget, @x = 0, @y = 0, @width = 0, @height = 0)
      @foregroundColor = Color::Silver
      @backgroundColor = Color::Black
      @children = [] of Widget
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
      limit += x + absolute_x if limit != 0
      each_char_pos(x, y, text) do |xx, yy, chr|
        limit_reached = limit > 0 && xx >= limit
        if limit_reached
          xx -= 1
          chr = '…'
        elsif chr == '\n'
          next unless stop_on_lf

          chr = '↵'
          limit_reached = true
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

    def handle_key_input(chr : Char, key : UInt16)
    end

    def invalidate
      @render_pending = true
      @children.each(&.invalidate)
    end
  end
end
