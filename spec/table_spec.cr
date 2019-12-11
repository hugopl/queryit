require "./spec_helper"

describe TextUi::Table do
  it "moves view port to right when needed" do
    ui = init_ui(12, 2)
    table = TextUi::Table.new(ui)
    table.width = ui.width
    table.height = ui.height
    ui.focus(table)

    table.set_data([%w(ABCD EFGH IJKL MNOP QRST),
                    %w(abcd efgh ijkl mnop qrst)])
    ui.render
    table.cursor_x.should eq(0)
    Terminal.to_s.should eq("ABCD EFGH I…\n" \
                            "abcd efgh i…\n")

    Terminal.inject_key_event(key: TextUi::KEY_ARROW_RIGHT)
    ui.process_events
    ui.render
    table.cursor_x.should eq(1)
    Terminal.to_s.should eq("ABCD EFGH I…\n" \
                            "abcd efgh i…\n")

    Terminal.inject_key_event(key: TextUi::KEY_ARROW_RIGHT)
    ui.process_events
    ui.render
    table.cursor_x.should eq(2)
    Terminal.to_s.should eq("…D EFGH IJKL\n" \
                            "…d efgh ijkl\n")

    Terminal.inject_key_event(key: TextUi::KEY_ARROW_RIGHT)
    ui.process_events
    ui.render
    table.cursor_x.should eq(3)
    Terminal.to_s.should eq("…H IJKL MNOP\n" \
                            "…h ijkl mnop\n")

    Terminal.inject_key_event(key: TextUi::KEY_ARROW_LEFT)
    ui.process_events
    ui.render
    table.cursor_x.should eq(2)
    Terminal.to_s.should eq("…H IJKL MNOP\n" \
                            "…h ijkl mnop\n")

    Terminal.inject_key_event(key: TextUi::KEY_ARROW_LEFT)
    ui.process_events
    ui.render
    table.cursor_x.should eq(1)
    Terminal.to_s.should eq("EFGH IJKL M…\n" \
                            "efgh ijkl m…\n")

    Terminal.inject_key_event(key: TextUi::KEY_ARROW_LEFT)
    ui.process_events
    ui.render
    table.cursor_x.should eq(0)
    Terminal.to_s.should eq("ABCD EFGH I…\n" \
                            "abcd efgh i…\n")
  end
end
