require "spec"
require "../src/textui/*"
require "../src/sql_beautifier/*"

# Wrapper module around termbox to make terminal UIs testable.
module TextUi
  class Terminal
    class Cell
      property chr
      property fg
      property bg

      def initialize(@chr = ' ', @fg = 0, @bg = 0)
      end
    end

    @@cells = Array(Array(Cell)).new
    @@cursor = {x: -1, y: -1}
    @@width = 20
    @@height = 4
    @@events = [] of Event

    def self.init(color_mode) : Void
      clear
    end

    def self.shutdown
    end

    def self.width
      @@width
    end

    def self.height
      @@height
    end

    def self.present
    end

    def self.clear
      @@cells.clear
      height.times do |y|
        @@cells << Array(Cell).new(width, Cell.new)
      end
    end

    def self.poll_event(event : Pointer(Event))
      event.value = @@events.shift
    end

    def self.peek_event(event : Pointer(Event), timeout : Int32 = 0) : Bool
      ev = @@events.shift?
      event.value = ev unless ev.nil?
      !ev.nil?
    end

    def self.set_cursor(x, y)
      @@cursor = {x: x, y: y}
    end

    def self.change_cell(x : Int32, y : Int32, chr : Char, foreground, background)
      if x >= width || y >= height
        puts "Tried to print #{chr.inspect} out of screen: #{x} >= #{width} or #{y} >= #{height}"
        return
      end
      @@cells[y][x] = Cell.new(chr, foreground.to_i, background.to_i)
    end

    # ## All method bellow are not part of Terminal interface ## #
    def self.cursor
      @@cursor
    end

    def self.resize(width, height)
      @@width = width
      @@height = height
      clear
      event = Event.new
      event.type = EVENT_RESIZE
      event.w = width
      event.x = height
      @@events << event
    end

    def self.clear_events
      @@events.clear
    end

    def self.inject_key_event(chr : Char) : Nil
      inject_key_event(0, chr.ord)
    end

    def self.inject_key_event(key = 0, ch = 0) : Nil
      ev = Event.new
      ev.type = EVENT_KEY
      ev.ch = ch
      ev.key = key
      @@events << ev
    end

    def self.to_s(colors = false)
      String.build do |io|
        print(io, info: false, colors: colors)
      end
    end

    def self.print(io = STDOUT, info = true, colors = false)
      io.puts("\nScreen size: #{width}x#{height}, cursor at #{@@cursor.inspect}") if info
      height.times do |y|
        line = @@cells[y].map do |cell|
          colors ? "#{((cell.fg << 16) | cell.bg).to_s(32)}" : cell.chr
        end
        if colors
          io.puts(line.join('-'))
        else
          io.puts(line.join)
        end
      end
    end
  end
end

alias Terminal = TextUi::Terminal

def init_ui(width = 20, height = 4)
  Terminal.resize(width, height)
  ui = TextUi::Ui.new
  ui.key_input_handler = ->(chr : Char, i : UInt16) {}
  ui.process_events # Process the resize event.
  ui
end

def print_ui
  TextUi::Terminal.print
end
