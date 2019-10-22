module TextUi
  class List < Widget
    property items
    property selected_item : Int32

    def initialize(parent, x = 0, y = 0, @items = [] of String)
      @selected_item = -1
      super(parent, x, y)
    end

    def select(item : String)
      idx = @items.index(item)
      return if idx.nil?

      @selected_item = idx
    end

    def render
      items.each_with_index do |item, i|
        debug("#{i} - #{item}, #{item.size} vs #{width} - height: #{height}")
        break if i >= height

        if i == selected_item
          puts(0, i, item, foregroundColor | Attr::Bold, stop_on_lf: true, limit: width)
        else
          puts(0, i, item, stop_on_lf: true, limit: width)
        end
      end
    end
  end
end
