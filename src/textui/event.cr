module TextUi
  class Event
    getter? accepted : Bool = false
  end

  class KeyEvent < Event
    getter char : Char
    getter key : UInt16
    getter modifier : UInt8

    def initialize(@char = '\0', @key = 0, @modifier = 0)
    end
  end
end
