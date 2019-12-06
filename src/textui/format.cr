module TextUi
  struct Format
    BOLD      = 0x0100
    UNDERLINE = 0x0200
    REVERSE   = 0x0400

    DEFAULT = Format.new

    getter foreground : UInt16
    getter background : UInt16

    def initialize(foreground : Color = Color::Silver, background : Color = Color::Black, bold = false, underline = false, reverse = false)
      @foreground = foreground.to_u16
      @foreground |= BOLD if bold
      @foreground |= UNDERLINE if underline
      @foreground |= REVERSE if reverse
      @background = background.to_u16
    end

    protected def initialize(@foreground, @background)
    end

    def reverse
      Format.new(@foreground | REVERSE, @background)
    end

    def underline
      Format.new(@foreground | UNDERLINE, @background)
    end

    def bold
      Format.new(@foreground | BOLD, @background)
    end
  end
end
