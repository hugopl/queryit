require "./spec_helper"

describe TextUi::Label do
  context "when managing cursor" do
    it "render cursor ok on a sequence of line feed" do
      ui = init_ui(12, 10)
      label = TextUi::Label.new(ui, 2, 2, "")
      label.width = 10
      label.height = 10
      label.accept_input
      label.cursor = 0
      ui.focus(label)
      ui.render
      Terminal.cursor.should eq({x: 2, y: 2})

      label.text = "\n\n\n"
      label.cursor = 2
      ui.invalidate
      ui.render
      Terminal.cursor.should eq({x: 2, y: 4})

      label.text = "123456789"
      label.cursor = 5
      ui.invalidate
      ui.render
      Terminal.cursor.should eq({x: 7, y: 2})

      label.text = "1234\n\n\n\n901"
      label.cursor = 10
      ui.invalidate
      ui.render
      Terminal.cursor.should eq({x: 4, y: 6})
    end

    it "ignores cursor larger than text" do
      ui = init_ui(10, 3)
      label = TextUi::Label.new(ui, 2, 2, "Foo")
      label.accept_input
      label.cursor = 1
      label.cursor = 4
      label.cursor.should eq(1)
      label.cursor = -1
      label.cursor.should eq(1)
    end

    it "move cursor if label text shrink" do
      ui = init_ui(20, 3)
      label = TextUi::Label.new(ui, 2, 2, "Long Text is Long")
      label.accept_input
      label.cursor = label.text.size
      label.text = "Hi"
      ui.focus(label)
      ui.render
      label.cursor.should eq(2)
    end
  end
end
