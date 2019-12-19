require "./spec_helper"
require "../src/query_control"

describe QueryControl do
  it "move cursor to right place after comment/uncoment a line" do
    ui = init_ui(80, 6)
    qc = QueryControl.new(ui)
    qc.handle_resize(80, 6)
    qc.query = "--hey"
    ui.focus(qc.focusable_widgets.first)
    Terminal.inject_key_event(key: TextUi::KEY_END)
    ui.process_events
    ui.render
    Terminal.cursor.should eq({x: 8, y: 1})

    Terminal.inject_key_event(key: TextUi::KEY_CTRL_SLASH)
    ui.process_events
    ui.render
    qc.query.should eq("hey")
    Terminal.cursor.should eq({x: 6, y: 1})

    Terminal.inject_key_event(key: TextUi::KEY_CTRL_SLASH)
    ui.process_events
    ui.render
    qc.query.should eq("-- hey")
    Terminal.cursor.should eq({x: 9, y: 1})

    Terminal.inject_key_event(key: TextUi::KEY_CTRL_SLASH)
    ui.process_events
    ui.render
    qc.query.should eq("hey")
    Terminal.cursor.should eq({x: 6, y: 1})
  end
end
