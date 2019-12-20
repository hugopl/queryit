require "./spec_helper"

describe TextUi::List do
  it "sets the cursor to the selected item" do
    ui = init_ui(7, 6)
    list = TextUi::List.new(ui, %w(one two three))
    list.resize(4, 3)
    list.cursor.should eq(0)
    list.select("two")
    list.cursor.should eq(1)
  end

  it "does not render an arrow when there's no item selected" do
    ui = init_ui(7, 6)
    list = TextUi::List.new(ui, 2, 2, %w(one two three))
    list.resize(5, 3)
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
    list.resize(5, 3)
    list.select(2)
    ui.render
    Terminal.to_s.should eq("       \n" \
                            "       \n" \
                            "   one \n" \
                            "   two \n" \
                            "  🠺thr…\n" \
                            "       \n")
  end

  it "adjusts the viewport to the cursor" do
    ui = init_ui(4, 4)
    list = TextUi::List.new(ui, (0..20).to_a.map(&.to_s))
    list.resize(4, 4)
    list.select(10)
    ui.render
    Terminal.to_s.should eq(" 7 ▲\n" \
                            " 8  \n" \
                            " 9  \n" \
                            "🠺10▼\n")
    list.select(3)
    ui.render
    Terminal.to_s.should eq("🠺3 ▲\n" \
                            " 4  \n" \
                            " 5  \n" \
                            " 6 ▼\n")
    list.select(4)
    ui.render
    Terminal.to_s.should eq(" 3 ▲\n" \
                            "🠺4  \n" \
                            " 5  \n" \
                            " 6 ▼\n")
    Terminal.clear
    list.resize(4, 1)
    ui.render
    Terminal.to_s.should eq("🠺4 ▲\n" \
                            "    \n" \
                            "    \n" \
                            "    \n")
    list.select(20)
    ui.render
    Terminal.to_s.should eq("🠺20▲\n" \
                            "    \n" \
                            "    \n" \
                            "    \n")
    list.resize(4, 4)
    ui.render
    Terminal.to_s.should eq(" 17▲\n" \
                            " 18 \n" \
                            " 19 \n" \
                            "🠺20 \n")
  end

  it "render focused item highlighted" do
    ui = init_ui(7, 6)
    list = TextUi::List.new(ui, 2, 2, %w(one two three))
    list.resize(5, 3)
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
    list.select(0)
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

  it "render list larger than viewport" do
    ui = init_ui(5, 4)
    list = TextUi::List.new(ui, 0, 0, %w(one two three four five six))
    list.resize(5, 4)
    list.select(3)
    ui.focus(list)
    ui.render
    Terminal.to_s.should eq(" one \n" \
                            " two \n" \
                            " thr…\n" \
                            "🠺fo…▼\n")
    Terminal.inject_key_event(key: TextUi::KEY_ARROW_DOWN)
    ui.process_events
    ui.render
    Terminal.to_s.should eq(" two▲\n" \
                            " thr…\n" \
                            "🠺four\n" \
                            " fi…▼\n")
    Terminal.inject_key_event(key: TextUi::KEY_ARROW_DOWN)
    ui.process_events
    ui.render
    Terminal.to_s.should eq(" th…▲\n" \
                            "🠺four\n" \
                            " five\n" \
                            " six \n")
    list.select("two")
    ui.render
    Terminal.to_s.should eq("🠺two▲\n" \
                            " thr…\n" \
                            " four\n" \
                            " fi…▼\n")
  end
end
