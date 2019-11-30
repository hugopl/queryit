require "./spec_helper"

describe TextUi::TextEditor do
  it "can open files" do
    ui = init_ui(20, 6)
    editor = TextUi::TextEditor.new(ui, 0, 0, 20, 6)
    editor.open("spec/fixtures/query.sql")
    ui.render
    Terminal.to_s.should eq("SELECT column1, col…\n" \
                            "  FROM fancy_table  \n" \
                            "  WHERE foo > bar   \n" \
                            "~                   \n" \
                            "~                   \n" \
                            "~                   \n")
  end

  it "invalidate extra cursors when text is replaced" do
    ui = init_ui(20, 6)
    editor = TextUi::TextEditor.new(ui, 0, 0, 20, 6)
    editor.open("spec/fixtures/query.sql")
    cursor1 = editor.cursor
    cursor1.move(1, 1)
    cursor2 = editor.create_cursor(2, 2)

    cursor1.valid?.should eq(true)
    cursor2.valid?.should eq(true)

    editor.text = ":-)"
    cursor1.valid?.should eq(true)
    cursor1.line.should eq(0)
    cursor1.col.should eq(0)
    cursor2.valid?.should eq(false)
    editor.cursors.should eq([cursor1])
  end

  it "can show line numbers" do
    ui = init_ui(20, 6)
    editor = TextUi::TextEditor.new(ui, 0, 0, 20, 6)
    editor.open("spec/fixtures/query.sql")
    editor.show_line_numbers = true
    ui.render
    Terminal.to_s.should eq("1│SELECT column1, c…\n" \
                            "2│  FROM fancy_table\n" \
                            "3│  WHERE foo > bar \n" \
                            "~                   \n" \
                            "~                   \n" \
                            "~                   \n")
  end

  it "can show larger line numbers" do
    ui = init_ui(20, 6)
    editor = TextUi::TextEditor.new(ui, 0, 0, 20, 6)
    editor.open("spec/fixtures/10_lines.sql")
    editor.show_line_numbers = true
    ui.render
    Terminal.to_s.should eq(" 1│one              \n" \
                            " 2│two              \n" \
                            " 3│three            \n" \
                            " 4│four             \n" \
                            " 5│five             \n" \
                            " 6│six              \n")
  end

  context "when navigating with arrows" do
    it "editor should start with a cursor" do
      ui = init_ui(20, 6)
      editor = TextUi::TextEditor.new(ui, 0, 0, 20, 6)
      editor.cursors.size.should eq(1)
    end

    it "go to end of line above on left key at column zero" do
      ui = init_ui(20, 6)
      editor = TextUi::TextEditor.new(ui, 0, 0, 20, 6)
      editor.text = "Line1\n\n\n"
      ui.focus(editor)
      cursor = editor.cursor
      cursor.move(2, 0)
      ui.render

      Terminal.inject_key_event(key: TextUi::KEY_ARROW_LEFT)
      ui.process_events
      cursor.line.should eq(1)
      cursor.col.should eq(0)

      Terminal.inject_key_event(key: TextUi::KEY_ARROW_LEFT)
      ui.process_events
      cursor.line.should eq(0)
      cursor.col.should eq(5)
    end

    it "preserve cursor column navigating on lines with different length" do
      ui = init_ui(20, 4)
      editor = TextUi::TextEditor.new(ui, 0, 0, 20, 4)
      editor.open("spec/fixtures/10_lines.sql")
      ui.focus(editor)
      cursor = editor.cursor

      ui.render
      Terminal.to_s.should eq("one                 \n" \
                              "two                 \n" \
                              "three               \n" \
                              "four                \n")

      Terminal.inject_key_event(key: TextUi::KEY_ARROW_DOWN)
      Terminal.inject_key_event(key: TextUi::KEY_ARROW_DOWN)
      Terminal.inject_key_event(key: TextUi::KEY_END)
      ui.process_queued_events
      cursor.col.should eq(5) # On end of "three"
      Terminal.inject_key_event(key: TextUi::KEY_ARROW_DOWN)
      ui.process_queued_events
      cursor.col.should eq(4) # On end of "four"
      Terminal.inject_key_event(key: TextUi::KEY_ARROW_UP)
      ui.process_queued_events
      cursor.col.should eq(5) # On end of "three"
      Terminal.inject_key_event(key: TextUi::KEY_ARROW_UP)
      ui.process_queued_events
      cursor.col.should eq(3) # On end of "two"
      Terminal.inject_key_event(key: TextUi::KEY_ARROW_LEFT)
      ui.process_queued_events
      cursor.col.should eq(2) # On end of "tw"
      Terminal.inject_key_event(key: TextUi::KEY_ARROW_DOWN)
      ui.process_queued_events
      cursor.col.should eq(2) # On end of "th"
      Terminal.inject_key_event(key: TextUi::KEY_ARROW_DOWN)
      ui.process_queued_events
      cursor.col.should eq(2) # On end of "fo"
    end

    it "go to next line on right arrow at end of a line" do
      ui = init_ui(20, 4)
      editor = TextUi::TextEditor.new(ui, 0, 0, 20, 4)
      ui.focus(editor)
      cursor = editor.cursor

      Terminal.inject_key_event(key: TextUi::KEY_ARROW_DOWN)
      ui.process_queued_events
      cursor.line.should eq(0)
      cursor.col.should eq(0)

      editor.text = "Line1\nLine2"
      Terminal.inject_key_event(key: TextUi::KEY_END)
      ui.process_queued_events
      cursor.col.should eq(5)
      Terminal.inject_key_event(key: TextUi::KEY_ARROW_RIGHT)
      ui.process_queued_events
      cursor.line.should eq(1)
      cursor.col.should eq(0)

      editor.text = "Line"
      cursor.move(0, 4)
      Terminal.inject_key_event(key: TextUi::KEY_ARROW_RIGHT)
      ui.process_queued_events
      cursor.line.should eq(0)
      cursor.col.should eq(4)
    end
  end

  context "when modifying contents" do
    it "it can insert/delete letters and lines" do
      ui = init_ui(20, 3)
      editor = TextUi::TextEditor.new(ui, 0, 0, 20, 3)
      ui.focus(editor)
      Terminal.inject_key_event('A')
      Terminal.inject_key_event('b')
      Terminal.inject_key_event('c')
      ui.process_queued_events
      ui.render
      Terminal.to_s.should eq("Abc                 \n" \
                              "~                   \n" \
                              "~                   \n")
      Terminal.inject_key_event(key: TextUi::KEY_ARROW_LEFT)
      Terminal.inject_key_event(key: TextUi::KEY_ENTER)
      Terminal.inject_key_event('B')
      ui.process_queued_events
      ui.render
      Terminal.to_s.should eq("Ab                  \n" \
                              "Bc                  \n" \
                              "~                   \n")
      Terminal.inject_key_event(key: TextUi::KEY_ARROW_RIGHT)
      Terminal.inject_key_event(key: TextUi::KEY_ENTER)
      Terminal.inject_key_event('D')
      ui.process_queued_events
      ui.render
      Terminal.to_s.should eq("Ab                  \n" \
                              "Bc                  \n" \
                              "D                   \n")

      Terminal.inject_key_event(key: TextUi::KEY_ARROW_UP)
      Terminal.inject_key_event(key: TextUi::KEY_DELETE)
      ui.process_queued_events
      ui.render
      Terminal.to_s.should eq("Ab                  \n" \
                              "B                   \n" \
                              "D                   \n")

      Terminal.inject_key_event(key: TextUi::KEY_DELETE)
      ui.process_queued_events
      ui.render
      Terminal.to_s.should eq("Ab                  \n" \
                              "BD                  \n" \
                              "~                   \n")
      Terminal.inject_key_event(key: TextUi::KEY_DELETE)
      ui.process_queued_events
      ui.render
      Terminal.to_s.should eq("Ab                  \n" \
                              "B                   \n" \
                              "~                   \n")

      Terminal.inject_key_event(key: TextUi::KEY_BACKSPACE)
      Terminal.inject_key_event(key: TextUi::KEY_BACKSPACE)
      ui.process_queued_events
      ui.render
      Terminal.to_s.should eq("Ab                  \n" \
                              "~                   \n" \
                              "~                   \n")

      editor.text = "A\nBug"
      editor.cursor.move(1, 0)
      Terminal.inject_key_event(key: TextUi::KEY_BACKSPACE)
      ui.process_queued_events
      ui.render
      Terminal.to_s.should eq("ABug                \n" \
                              "~                   \n" \
                              "~                   \n")
      editor.cursor.line.should eq(0)
      editor.cursor.col.should eq(1)

      Terminal.inject_key_event(key: TextUi::KEY_BACKSPACE)
      ui.process_queued_events
      ui.render
      Terminal.to_s.should eq("Bug                 \n" \
                              "~                   \n" \
                              "~                   \n")

      Terminal.inject_key_event(key: TextUi::KEY_BACKSPACE)
      ui.process_queued_events
      ui.render
      Terminal.to_s.should eq("Bug                 \n" \
                              "~                   \n" \
                              "~                   \n")

      editor.text = ""
      editor.cursor.move(0, 0)
      Terminal.inject_key_event(key: TextUi::KEY_DELETE)
      ui.process_queued_events
      ui.render
      Terminal.to_s.should eq("                    \n" \
                              "~                   \n" \
                              "~                   \n")
    end

    it "can edit and save files" do
      ui = init_ui(20, 3)
      editor = TextUi::TextEditor.new(ui, 0, 0, 20, 3)
      editor.open("spec/fixtures/query.sql")
      ui.focus(editor)
      Terminal.inject_key_event('A')
      Terminal.inject_key_event(key: TextUi::KEY_ENTER)
      Terminal.inject_key_event('B')
      ui.process_queued_events
      contents = String.build do |str|
        editor.save(str)
      end
      contents.should eq("A\nBSELECT column1, column2\n" \
                         "  FROM fancy_table\n" \
                         "  WHERE foo > bar\n"
      )
    end
  end

  pending "has insert mode"
  pending "can wrap lines"
  pending "can have multiple cursors"
  pending "only render changed lines"
  pending "can select text with keyboard (not sure if termbox and general terminals will handle this)"
  pending "can undo/redo"
  pending "can syntax highlight text"
end
