require "./spec_helper"

describe TextUi::Widget do
  context "when printing strings" do
    it "obey alignment on line feed" do
      ui = init_ui(12, 3)
      ui.print_lines(1, 1, "LineFeed\nHere")
      Terminal.to_s.should eq("            \n" \
                              " LineFeed   \n" \
                              " Here       \n")
    end

    it "prints line feed if stopped at it" do
      ui = init_ui(12, 3)
      ui.print_line(1, 1, "LineFeed\nHere", width: 11)
      Terminal.to_s.should eq("            \n" \
                              " LineFeed↵H…\n" \
                              "            \n")
    end

    it "replaces \\r by ␍" do
      ui = init_ui(7, 1)
      ui.print_lines(0, 0, "CR\rhere")
      Terminal.to_s.should eq("CR␍here\n")
    end

    it "prints ellipsis if the text is too long" do
      ui = init_ui(4, 1)
      ui.print_line(0, 0, "123456", width: 4)
      Terminal.to_s.should eq("123…\n")
    end

    it "does not prints ellipsis if the text is exact the width size" do
      ui = init_ui(4, 1)
      ui.print_line(0, 0, "1234", width: 4)
      Terminal.to_s.should eq("1234\n")
      ui.print_lines(0, 0, "1234", width: 4)
      Terminal.to_s.should eq("1234\n")
    end
  end

  context "when rendering children" do
    it "obey children coordinates" do
      ui = init_ui(18, 11)
      box1 = TextUi::Box.new(ui, 2, 2, 16, 9, "box1")
      box2 = TextUi::Box.new(box1, 1, 1, 14, 7, "box2")
      box3 = TextUi::Box.new(box2, 1, 1, 12, 5, "box3")
      ui.render
      box3.print_line(5, 2, "Hi")
      Terminal.to_s.should eq("                  \n" \
                              "                  \n" \
                              "  ╭─ box1 ───────╮\n" \
                              "  │╭─ box2 ─────╮│\n" \
                              "  ││╭─ box3 ───╮││\n" \
                              "  │││          │││\n" \
                              "  │││    Hi    │││\n" \
                              "  │││          │││\n" \
                              "  ││╰──────────╯││\n" \
                              "  │╰────────────╯│\n" \
                              "  ╰──────────────╯\n")
    end

    it "prints ellipsis on nested children" do
      ui = init_ui(18, 11)
      box1 = TextUi::Box.new(ui, 2, 2, 16, 9, "box1")
      box2 = TextUi::Box.new(box1, 1, 1, 14, 7, "box2")
      box3 = TextUi::Box.new(box2, 1, 1, 12, 5, "box3")
      ui.render
      box3.print_lines(5, 2, "123456789", width: 6)
      Terminal.to_s.should eq("                  \n" \
                              "                  \n" \
                              "  ╭─ box1 ───────╮\n" \
                              "  │╭─ box2 ─────╮│\n" \
                              "  ││╭─ box3 ───╮││\n" \
                              "  │││          │││\n" \
                              "  │││    12345…│││\n" \
                              "  │││          │││\n" \
                              "  ││╰──────────╯││\n" \
                              "  │╰────────────╯│\n" \
                              "  ╰──────────────╯\n")
    end

    it "does not render cursor out of widget area" do
      ui = init_ui(18, 11)
      box1 = TextUi::Box.new(ui, 2, 2, 16, 9, "box1")
      box2 = TextUi::Box.new(box1, 1, 1, 14, 7, "box2")
      box2.set_cursor(0, 0)
      Terminal.cursor.should eq({x: 3, y: 3})
      box2.set_cursor(0, -1)
      Terminal.cursor.should eq({x: -1, y: -1})
      box2.set_cursor(20, 30)
      Terminal.cursor.should eq({x: -1, y: -1})
    end
  end
end
