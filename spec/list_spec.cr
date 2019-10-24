require "./spec_helper"

describe TextUi::List do
  it "render list without an arrow when there's no item selected" do
    ui = init_ui(7, 6)
    list = TextUi::List.new(ui, 2, 2, %w(one two three))
    list.width = 5
    ui.render
    Terminal.to_s.should eq("       \n" \
                            "       \n" \
                            "   one \n" \
                            "   two \n" \
                            "   thr…\n" \
                            "       \n")
  end

  it "render an arrow on selected item" do
    ui = init_ui(7, 6)
    list = TextUi::List.new(ui, 2, 2, %w(one two three))
    list.width = 5
    list.selected_item = 2
    ui.render
    Terminal.to_s.should eq("       \n" \
                            "       \n" \
                            "   one \n" \
                            "   two \n" \
                            "  🠺thr…\n" \
                            "       \n")
  end

  it "render focused item highlighted" do
    ui = init_ui(7, 6)
    list = TextUi::List.new(ui, 2, 2, %w(one two three))
    list.width = 5
    ui.render
    Terminal.to_s.should eq("       \n" \
                            "       \n" \
                            "   one \n" \
                            "   two \n" \
                            "   thr…\n" \
                            "       \n")
    Terminal.to_s(colors: true).should eq("0-0-0-0-0-0-0\n" \
                                          "0-0-0-0-0-0-0\n" \
                                          "0-0-e000-e000-e000-e000-e000\n" \
                                          "0-0-e000-e000-e000-e000-e000\n" \
                                          "0-0-e000-e000-e000-e000-e000\n" \
                                          "0-0-0-0-0-0-0\n")
    ui.focus(list)
    ui.render
    Terminal.to_s(colors: true).should eq("0-0-0-0-0-0-0\n" \
                                          "0-0-0-0-0-0-0\n" \
                                          "0-0-e000-20e000-20e000-20e000-20e000\n" \
                                          "0-0-e000-e000-e000-e000-e000\n" \
                                          "0-0-e000-e000-e000-e000-e000\n" \
                                          "0-0-0-0-0-0-0\n")
    list.selected_item = 0
    ui.invalidate
    ui.render
    Terminal.to_s.should eq("       \n" \
                            "       \n" \
                            "  🠺one \n" \
                            "   two \n" \
                            "   thr…\n" \
                            "       \n")
    Terminal.to_s(colors: true).should eq("0-0-0-0-0-0-0\n" \
                                          "0-0-0-0-0-0-0\n" \
                                          "0-0-e000-20e000-20e000-20e000-20e000\n" \
                                          "0-0-e000-e000-e000-e000-e000\n" \
                                          "0-0-e000-e000-e000-e000-e000\n" \
                                          "0-0-0-0-0-0-0\n")
    list.cursor = 1
    ui.invalidate
    ui.render
    Terminal.to_s(colors: true).should eq("0-0-0-0-0-0-0\n" \
                                          "0-0-0-0-0-0-0\n" \
                                          "0-0-e000-e000-e000-e000-e000\n" \
                                          "0-0-e000-20e000-20e000-20e000-20e000\n" \
                                          "0-0-e000-e000-e000-e000-e000\n" \
                                          "0-0-0-0-0-0-0\n")
  end
end
