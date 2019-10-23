require "./spec_helper"

describe TextUi::Widget do
  context "when printing strings" do
    it "obey alignment on line feed" do
      ui = init_ui(12, 3)
      ui.puts(1, 1, "LineFeed\nHere")
      Terminal.to_s.should eq("            \n" \
                              " LineFeed   \n" \
                              " Here       \n")
    end

    it "prints line feed if stopped at it" do
      ui = init_ui(12, 3)
      ui.puts(1, 1, "LineFeed\nHere", stop_on_lf: true)
      Terminal.to_s.should eq("            \n" \
                              " LineFeed↵  \n" \
                              "            \n")
    end

    it "replaces \\r by ␍" do
      ui = init_ui(7, 1)
      ui.puts(0, 0, "CR\rhere")
      Terminal.to_s.should eq("CR␍here\n")
    end

    it "prints ellipsis if the text is too long" do
      ui = init_ui(4, 1)
      ui.puts(0, 0, "123456", stop_on_lf: true, limit: 4)
      Terminal.to_s.should eq("123…\n")
    end

    it "does not prints ellipsis if the text is exact the limti size" do
      ui = init_ui(4, 1)
      ui.puts(0, 0, "1234", stop_on_lf: true, limit: 4)
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
      box3.puts(5, 2, "Hi")
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
      box3.puts(5, 2, "123456789", limit: 6)
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
  end
end
