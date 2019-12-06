module TextUi
  class List < Widget
    property items
    getter cursor : Int32
    setter on_select : Proc(String, Nil)?

    property focused_format : Format

    def initialize(parent, x = 0, y = 0, @items = [] of String)
      super(parent, x, y, 4, @items.size)
      @selected_item = -1
      @cursor = 0
      @viewport = 0
      @focused_format = @default_format.reverse
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
        format = item_idx == @cursor && focused? ? @focused_format : default_format

        arrow = item_idx == @selected_item ? '🠺' : ' '
        print_char(0, i, arrow, default_format)

        if (i == 0 && has_scrollup) || (has_scrolldown && i == height - 1)
          limit -= 1
          print_char(width - 1, i, i.zero? ? '▲' : '▼')
        end

        print_line(1, i, item, format, width: limit)
      end
    end

    def handle_key_input(chr : Char, key : UInt16)
      super
      return if @items.empty?

      case key
      when KEY_ARROW_UP   then @cursor -= 1
      when KEY_ARROW_DOWN then @cursor += 1
      when KEY_ENTER
        @selected_item = @cursor
        on_select = @on_select
        on_select.call(@items[@selected_item]) if on_select
      end

      @cursor = @cursor.clamp(0, @items.size - 1)

      if @cursor - @viewport >= height
        @viewport += 1
      elsif @cursor < @viewport
        @viewport -= 1
      end
      invalidate
    end
  end
end
