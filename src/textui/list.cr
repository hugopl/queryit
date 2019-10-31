module TextUi
  class List < Widget
    property items
    getter cursor : Int32
    setter on_select : Proc(String, Nil)?

    def initialize(parent, x = 0, y = 0, @items = [] of String)
      super(parent, x, y, 4, @items.size)
      @selected_item = -1
      @cursor = 0
      @viewport = 0
    end

    def select(item : String) : Nil
      idx = @items.index(item)

      return if idx.nil?
      self.select(idx)
    end

    def select(item_idx : Int32) : Nil
      return if item_idx < 0 || item_idx >= @items.size

      @selected_item = item_idx
      self.cursor = item_idx
      invalidate
    end

    def cursor=(cursor : Int32) : Nil
      return if cursor < 0

      @viewport = cursor if cursor < @viewport
      @cursor = cursor
      invalidate
    end

    def render
      has_scrollup = @viewport > 0
      has_scrolldown = @items.size - @viewport > height

      height.times do |i|
        item_idx = i + @viewport
        break if i >= height || item_idx >= @items.size

        item = @items[item_idx]
        limit = width - 1
        color = foregroundColor

        arrow = item_idx == @selected_item ? '🠺' : ' '
        putc(0, i, arrow, color)

        color |= Attr::Reverse if item_idx == @cursor && focused?

        if (i == 0 && has_scrollup) || (has_scrolldown && i == height - 1)
          limit -= 1
          putc(width - 1, i, i.zero? ? '▲' : '▼')
        end

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
      if @cursor - @viewport >= height
        @viewport += 1
      elsif @cursor < @viewport
        @viewport -= 1
      end
      invalidate
    end
  end
end
