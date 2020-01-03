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

    def reverse?
      @foreground & REVERSE == REVERSE
    end

    def underline
      Format.new(@foreground | UNDERLINE, @background)
    end

    def underline?
      @foreground & UNDERLINE == UNDERLINE
    end

    def bold
      Format.new(@foreground | BOLD, @background)
    end

    def bold?
      @foreground & BOLD == BOLD
    end

    def inspect(io : IO)
      io << "<Fmt #{foreground & 0xF0FF}:#{@background & 0xF0FF}"
      io << ' ' if @foreground > 0xFF
      io << "r" if reverse?
      io << "b" if bold?
      io << "u" if underline?
      io << '>'
    end
  end
end
