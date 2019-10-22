module TextUi
  class List < Widget
    property items
    property selected_item

    def initialize(parent, x = 0, y = 0, @items = [] of String, @selected_item = -1)
      super(parent, x, y)
    end

    def render
      items.each_with_index do |item, i|
        debug("#{i} - #{item}, #{item.size} vs #{width} - height: #{height}")
        break if i >= height
        puts(0, i, item, stop_on_lf: true, limit: width)
      end
    end
  end
end
