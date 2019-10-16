require "./widget"

module TextUi
  class Box < Widget
    property borderColor

    def initialize(parent, @title : String)
      super(parent)
      @borderColor = Color::Teal
    end

    def render
      # Top
      putc(1, 0, '─', @borderColor)
      puts(3, 0, @title)
      (width - @title.size - 5).times { |i| putc(@title.size + 4 + i, 0, '─', @borderColor) }
      # Left
      (height - 2).times { |i| putc(0, i + 1, '│', @borderColor) }
      # Bottom
      (width - 2).times { |i| putc(i + 1, height - 1, '─', @borderColor) }
      # Right
      (height - 2).times { |i| putc(width - 1, i + 1, '│', @borderColor) }
      # Corners
      putc(0, 0, '┌', @borderColor)
      putc(width - 1, 0, '┐', @borderColor)
      putc(0, height - 1, '└', @borderColor)
      putc(width - 1, height - 1, '┘', @borderColor)
    end
  end
end
