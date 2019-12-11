module TextUi
  abstract class Widget
    property x
    property y
    property width
    property height
    property default_format : Format
    property? visible : Bool
    property? focused : Bool

    delegate :<<, to: @children
    getter children
    getter parent
    protected property? render_pending

    def initialize(@parent : Widget, @x = 0, @y = 0, @width = 1, @height = 1)
      @default_format = Format.new(Color::Silver)
      @children = [] of Widget
      @focused = false
      @visible = true
      @render_pending = true
      @parent << self if @parent != self
    end

    def ui
      parent = @parent
      loop do
        return parent if parent.is_a?(Ui)
        parent = parent.parent
      end
    end

    def destroy
      parent.children.delete(self)
    end

    def resize(@width, @height)
      invalidate
    end

    def move(@x, @y)
      invalidate
    end

    def children_focused?
      children.any?(&.focused?)
    end

    def clear_text(x, y, text : String, format : Format = @default_format, stop_on_lf = false)
      each_char_pos(x, y, text) do |xx, yy, chr|
        if chr == '\n'
          break if stop_on_lf
          next
        end
        Terminal.change_cell(xx, yy, ' ', format)
      end
    end

    def clear_text(x, y, n : Int32, format : Format = @default_format, stop_on_lf = false)
      x += absolute_x
      y += absolute_y
      n.times do |i|
        Terminal.change_cell(x + i, y, ' ', format)
      end
    end

    def erase
      width.times do |x|
        height.times do |y|
          print_char(x, y, ' ', @default_format)
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

    def print_line(x : Int32, y : Int32, text : String,
                   format : Format = @default_format,
                   offset = 0,
                   count = text.size,
                   width = 0,
                   ellipsis = true) : Nil
      x += absolute_x
      y += absolute_y
      width_alert = width - 1

      offset.upto(text.size - 1) do |char_idx|
        chr = text[char_idx]
        i = char_idx - offset
        break if i == count || width != 0 && i >= width

        if ellipsis && i == width_alert && text.size != width
          chr = '…'
        elsif chr == '\n'
          chr = '↵'
        elsif chr == '\r'
          chr = '␍'
        end
        Terminal.change_cell(x + i, y, chr, format)
      end

      return if count >= width

      # fill width with blanks
      start_x = x + count
      (width - count).times do |ii|
        Terminal.change_cell(start_x + ii, y, ' ', format)
      end
    end

    def print_lines(x, y, text : String, format : Format = @default_format, width = 0)
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
        Terminal.change_cell(xx, yy, chr, format)
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

    def print_char(x : Int32, y : Int32, chr : Char, format : Format = @default_format)
      x += absolute_x
      y += absolute_y
      Terminal.change_cell(x, y, chr, format)
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

    def children?(widget : Widget) : Bool
      return true if children.includes?(widget)

      children.any?(&.children?(widget))
    end

    def handle_key_input(chr : Char, key : UInt16)
    end

    def invalidate
      @render_pending = true
      @children.each(&.invalidate)
    end
  end
end
