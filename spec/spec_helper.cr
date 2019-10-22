require "spec"
require "../src/textui/*"

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
      @@events << event
    end

    def self.clear_events
      @@events.clear
    end

    def self.to_s
      String.build do |io|
        print(io, info: false)
      end
    end

    def self.print(io = STDOUT, info = true)
      io.puts("\nScreen size: #{width}x#{height}, cursor at #{@@cursor.inspect}") if info
      height.times do |y|
        @@cells[y].each do |cell|
          io.print cell.chr
        end
        io.puts
      end
    end
  end
end

alias Terminal = TextUi::Terminal

def init_ui(width = 20, height = 4)
  Terminal.resize(width, height)
  Terminal.clear_events
  TextUi::Ui.new
end

def print_ui
  TextUi::Terminal.print
end
