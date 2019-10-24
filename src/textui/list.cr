module TextUi
  class List < Widget
    property items
    property selected_item : Int32
    property cursor : Int32
    setter on_select : Proc(String, Nil)?

    def initialize(parent, x = 0, y = 0, @items = [] of String)
      @selected_item = -1
      @cursor = 0
      super(parent, x, y, 4, @items.size)
    end

    def select(item : String)
      idx = @items.index(item)
      return if idx.nil?

      @selected_item = idx
    end

    def render
      limit = width - 1
      items.each_with_index do |item, i|
        break if i >= height

        color = foregroundColor

        arrow = i == @selected_item ? '🠺' : ' '
        putc(0, i, arrow, color)

        color |= Attr::Reverse if i == @cursor && focused?
        puts(1, i, item, color, stop_on_lf: true, limit: limit)
        clear_text(item.size + 1, i, limit - item.size, color)
      end
    end

    def handle_key_input(chr : Char, key : UInt16)
      case key
      when KEY_ARROW_UP   then @cursor -= 1
      when KEY_ARROW_DOWN then @cursor += 1
      when KEY_ENTER
        @selected_item = @cursor
        on_select = @on_select
        on_select.call(@items[@selected_item]) if on_select
      end

      if @cursor < 0
        @cursor = 0
      elsif @cursor >= @items.size - 1
        @cursor = @items.size - 1
      end
      invalidate
    end
  end
end
