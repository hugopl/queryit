require "./spec_helper"

describe TextUi::Label do
  context "when managing cursor" do
    it "render cursor ok on a sequence of line feed" do
      ui = init_ui(12, 10)
      label = TextUi::Label.new(ui, 2, 2, "")
      label.accept_input
      label.cursor = 0
      ui.render
      Terminal.cursor.should eq({x: 2, y: 2})

      label.text = "\n\n\n"
      label.cursor = 2
      ui.render
      Terminal.cursor.should eq({x: 2, y: 4})

      label.text = "123456789"
      label.cursor = 5
      ui.render
      Terminal.cursor.should eq({x: 7, y: 2})

      label.text = "1234\n\n\n\n901"
      label.cursor = 10
      ui.render
      Terminal.cursor.should eq({x: 4, y: 6})
    end

    it "ignores cursor larger than text" do
      ui = init_ui(10, 1)
      label = TextUi::Label.new(ui, 2, 2, "Foo")
      label.accept_input
      label.cursor = 1
      label.cursor = 4
      label.cursor.should eq(1)
      label.cursor = -1
      label.cursor.should eq(1)
    end

    it "move cursor if label text shrink" do
      ui = init_ui(20, 1)
      label = TextUi::Label.new(ui, 2, 2, "Long Text is Long")
      label.accept_input
      label.cursor = label.text.size
      label.text = "Hi"
      label.cursor.should eq(2)
    end
  end
end
