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

    it "prints ellipsis if the text is too long" do
      ui = init_ui(4, 1)
      ui.puts(0, 0, "123456", stop_on_lf: true, limit: 4)
      Terminal.to_s.should eq("123…\n")
    end
  end
end
