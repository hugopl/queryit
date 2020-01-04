module TextUi
  class Event
    getter? accepted : Bool = false

    def accept
      @accepted = true
    end
  end

  class KeyEvent < Event
    getter char : Char
    getter key : UInt16
    getter alt : UInt8

    def initialize(@char = '\0', @key = 0, @alt = 0)
    end

    def alt?
      @alt != 0
    end
  end
end
