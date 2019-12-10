require "./widget"

module TextUi
  class Box < Widget
    property border_color
    property border_style : BorderStyle

    enum Docking
      None
      Left
      Right
    end

    enum BorderStyle
      RoundedBorder
      Fancy
    end

    @docking = Docking::None
    @border_color = Format.new(Color::Teal)
    @border_style = BorderStyle::RoundedBorder

    def initialize(parent, @title : String, @shortcut : String = "")
      super(parent)
    end

    def initialize(parent, x, y, width, height, @title : String, @shortcut : String = "")
      super(parent, x, y, width, height)
    end

    def right_of(another : Box)
      self.x = another.width - 1
      self.y = another.y
      @docking = Docking::Right
    end

    def render
      case @border_style
      when BorderStyle::Fancy         then render_fancy_style
      when BorderStyle::RoundedBorder then render_rounded_border_style
      end
    end

    def render_rounded_border_style
      style = border_style
      # Top
      print_char(1, 0, style[:horizontal], @border_color)
      print_line(3, 0, @title)
      print_line(@title.size + 4, 0, @shortcut, @border_color.reverse.bold)
      (width - @title.size - @shortcut.size - 5).times do |i|
        print_char(@title.size + @shortcut.size + 4 + i, 0, style[:horizontal], @border_color)
      end
      # Left
      (height - 2).times { |i| print_char(0, i + 1, style[:vertical], @border_color) } unless @docking == Docking::Right
      # Bottom
      (width - 2).times { |i| print_char(i + 1, height - 1, style[:horizontal], @border_color) }
      # Right
      (height - 2).times { |i| print_char(width - 1, i + 1, style[:vertical], @border_color) }
      # Corners
      print_char(0, 0, style[:top_left], @border_color)
      print_char(width - 1, 0, style[:top_right], @border_color)
      print_char(0, height - 1, style[:bottom_left], @border_color)
      print_char(width - 1, height - 1, style[:bottom_right], @border_color)
    end

    private def border_style
      left_corners = if @docking == Docking::Right
                       {top: '┬', bottom: '┴'}
                     else
                       {top: '╭', bottom: '╰'}
                     end
      {horizontal: '─', vertical: '│', top_right: '╮', bottom_right: '╯', bottom_left: left_corners[:bottom], top_left: left_corners[:top]}
    end

    private def render_fancy_style
      print_line(0, 0, "██", @border_color)
      print_line(2, 0, @title, @border_color.reverse)
      print_line(2 + @title.size, 0, "┊", @border_color.reverse)
      print_line(3 + @title.size, 0, @shortcut, @border_color.reverse)
      title_bar_remain = width//3 - 3 - @title.size - @shortcut.size - 3
      title_bar_remain.times do |i|
        print_char(@title.size + @shortcut.size + 3 + i, 0, '█', @border_color)
      end
      title_bar_remain = 0 if title_bar_remain < 0
      print_line(title_bar_remain + 3 + @title.size + @shortcut.size, 0, "▓▒░", @border_color)

      (height - 2).times { |i| print_char(0, i + 1, '┃', @border_color) }
      print_char(0, height - 2, '┇', @border_color)
    end
  end
end
