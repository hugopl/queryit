module TextUi
  abstract class Widget
    property x
    property y
    property width
    property height
    property foregroundColor
    property backgroundColor
    property? visible : Bool
    property? focused : Bool
    setter key_input_handler : Proc(Char, UInt16, Nil)?

    delegate :<<, to: @children
    getter children
    protected property? render_pending

    def initialize(@parent : Widget, @x = 0, @y = 0, @width = 0, @height = 0)
      @foregroundColor = Color::Silver
      @backgroundColor = Color::Black
      @children = [] of Widget
      @focused = false
      @visible = true
      @render_pending = true
      @parent << self if @parent != self
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

    def erase
      width.times do |x|
        height.times do |y|
          print_char(x, y, ' ', Color::White, Color::Black)
        end
      end
    end

    def set_cursor(x, y)
      if x < 0 || y < 0 || x >= width || y >= height
        Terminal.set_cursor(-1, -1)
      else
        Terminal.set_cursor(x + absolute_x, y + absolute_y)
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

    def print_line(x : Int32, y : Int32, text : String, foreground = @foregroundColor, background = @backgroundColor, width = 0) : Nil
      x += absolute_x
      y += absolute_y
      width_alert = width - 1

      text.each_char_with_index do |chr, i|
        break if width != 0 && i >= width

        if i == width_alert && text.size != width
          chr = '…'
        elsif chr == '\n'
          chr = '↵'
        elsif chr == '\r'
          chr = '␍'
        end
        Terminal.change_cell(x + i, y, chr, foreground, background)
      end

      # fill width with blanks
      start_x = x + text.size
      (width - text.size).times do |i|
        Terminal.change_cell(start_x + i, y, ' ', foreground, background)
      end
    end

    def print_lines(x, y, text : String, foreground = @foregroundColor, background = @backgroundColor, width = 0)
      count = 0
      width = 0 if text.size <= width # Turn off width if the string fits
      each_char_pos(x, y, text) do |xx, yy, chr|
        count += 1
        limit_reached = count >= width if width != 0
        if limit_reached
          chr = '…'
        elsif chr == '\n'
          next
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

    def print_char(x : Int32, y : Int32, chr : Char, foreground = @foregroundColor, background = @backgroundColor)
      x += absolute_x
      y += absolute_y
      Terminal.change_cell(x, y, chr, foreground, background)
    end

    protected def render_children
      @children.each do |child|
        if child.render_pending?
          child.render_pending = false
          child.render if child.visible?
        end
        child.render_children
      end
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
