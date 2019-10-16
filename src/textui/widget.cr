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
        TermboxBindings.tb_change_cell(xx, yy, ' '.ord, foreground, background)
      end
    end

    def puts(x, y, text : String, foreground = @foregroundColor, background = @backgroundColor, stop_on_lf = false, limit = 0)
      i = 0
      each_char_pos(x, y, text) do |xx, yy, chr|
        limit_reached = limit > 0 && xx > limit
        if limit_reached
          xx -= 1
          chr = '…'
        elsif chr == '\n'
          next unless stop_on_lf

          chr = '↵'
          limit_reached = true
        end
        TermboxBindings.tb_change_cell(xx, yy, chr.ord, foreground, background)
        break if limit_reached
      end
    end

    def each_char_pos(x, y, text : String)
      origin_x = x + @x + @parent.x
      x_limit = @width + origin_x - 1
      x = origin_x
      y += @y + @parent.y
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

    def putc(x, y, chr : Char, foreground = 33, background = 0)
      x += @x + @parent.x
      y += @y + @parent.y
      TermboxBindings.tb_change_cell(x, y, chr.ord, foreground, background)
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
