require "./widget"

module TextUi
  class Box < Widget
    property borderColor

    enum Docking
      None
      Left
      Right
    end

    def initialize(parent, @title : String)
      super(parent)
      @docking = Docking::None
      @borderColor = Color::Teal
    end

    def right_of(another : Box)
      self.x = another.width - 1
      self.y = another.y
      @docking = Docking::Right
    end

    def render
      style = border_style
      # Top
      putc(1, 0, style[:horizontal], @borderColor)
      puts(3, 0, @title)
      (width - @title.size - 5).times { |i| putc(@title.size + 4 + i, 0, style[:horizontal], @borderColor) }
      # Left
      (height - 2).times { |i| putc(0, i + 1, style[:vertical], @borderColor) } unless @docking == Docking::Right
      # Bottom
      (width - 2).times { |i| putc(i + 1, height - 1, style[:horizontal], @borderColor) }
      # Right
      (height - 2).times { |i| putc(width - 1, i + 1, style[:vertical], @borderColor) }
      # Corners
      putc(0, 0, style[:top_left], @borderColor)
      putc(width - 1, 0, style[:top_right], @borderColor)
      putc(0, height - 1, style[:bottom_left], @borderColor)
      putc(width - 1, height - 1, style[:bottom_right], @borderColor)
    end

    private def border_style
      left_corners = if @docking == Docking::Right
                       {top: '┬', bottom: '┴'}
                     else
                       {top: '╭', bottom: '╰'}
                     end
      {horizontal: '─', vertical: '│', top_right: '╮', bottom_right: '╯', bottom_left: left_corners[:bottom], top_left: left_corners[:top]}
    end
  end
end
