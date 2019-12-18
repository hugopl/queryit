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

  it "invalidates extra cursors when text is replaced" do
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
    it "starts with a cursor" do
      ui = init_ui(20, 6)
      editor = TextUi::TextEditor.new(ui, 0, 0, 20, 6)
      editor.cursors.size.should eq(1)
    end

    it "goes to end of line above on left key at column zero" do
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

    it "preserves cursor column navigating on lines with different length" do
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
      cursor.line.should eq(2)
      cursor.col.should eq(5) # On end of "three"
      Terminal.inject_key_event(key: TextUi::KEY_ARROW_DOWN)
      ui.process_queued_events
      cursor.col.should eq(4) # On end of "four"

      Terminal.inject_key_event(key: TextUi::KEY_INSERT) # This should not change anything
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

    it "goes to next line on right arrow at end of a line" do
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

    it "doesn't loose the cursor when word-wrap is enabled" do
      ui = init_ui(20, 7)
      editor = TextUi::TextEditor.new(ui, 0, 0, 20, 7)
      ui.focus(editor)
      editor.text = "Hi\nThis is a long line that span for 3 rows so I can test it.\n\nOk then."
      editor.word_wrap = true
      cursor = editor.cursor
      ui.render
      Terminal.to_s.should eq("Hi                  \n" \
                              "This is a long line \n" \
                              "that span for 3 rows\n" \
                              " so I can test it.  \n" \
                              "                    \n" \
                              "Ok then.            \n" \
                              "~                   \n")

      # Put cursor at end of "so I can test it."
      Terminal.inject_key_event(key: TextUi::KEY_ARROW_DOWN)
      Terminal.inject_key_event(key: TextUi::KEY_END)
      ui.process_queued_events
      cursor.line.should eq(1)
      cursor.col.should eq(58)
      ui.render
      Terminal.cursor.should eq({x: 18, y: 3})

      # Put cursor at "w" of "that span for 3 rows"
      Terminal.inject_key_event(key: TextUi::KEY_ARROW_UP)
      ui.process_queued_events
      cursor.line.should eq(1)
      cursor.col.should eq(38)
      ui.render
      Terminal.cursor.should eq({x: 18, y: 2})

      # Put cursor back at end of "so I can test it."
      Terminal.inject_key_event(key: TextUi::KEY_ARROW_DOWN)
      ui.process_queued_events
      cursor.line.should eq(1)
      cursor.col.should eq(58)
      ui.render
      Terminal.cursor.should eq({x: 18, y: 3})

      # Turn on line number and see if cursors still in the same text position
      editor.show_line_numbers = true
      ui.render
      Terminal.to_s.should eq("1│Hi                \n" \
                              "2│This is a long    \n" \
                              " │line that span for\n" \
                              " │ 3 rows so I can  \n" \
                              " │test it.          \n" \
                              "3│                  \n" \
                              "4│Ok then.          \n")
      Terminal.cursor.should eq({x: 10, y: 4})

      # Put cursor at the start of the empty line 3
      Terminal.inject_key_event(key: TextUi::KEY_ARROW_DOWN)
      ui.process_queued_events
      ui.render
      cursor.line.should eq(2)
      cursor.col.should eq(0)
      Terminal.cursor.should eq({x: 2, y: 5})

      # Put cursor at the of "Ok then.""
      Terminal.inject_key_event(key: TextUi::KEY_ARROW_DOWN)
      ui.process_queued_events
      ui.render
      cursor.line.should eq(3)
      cursor.col.should eq(8)
      Terminal.cursor.should eq({x: 10, y: 6})

      # Put cursor at last space of "This is a long "
      cursor.move(1, 14)
      ui.invalidate
      ui.render
      Terminal.cursor.should eq({x: 16, y: 1})

      # Put cursor at "l" of "line that span"
      cursor.move(1, 15)
      ui.invalidate
      ui.render
      Terminal.cursor.should eq({x: 2, y: 2})
    end

    it "doesn't loose the cursor when word-wrap is enabled - second round" do
      ui = init_ui(20, 7)
      editor = TextUi::TextEditor.new(ui, 0, 0, 20, 7)
      ui.focus(editor)
      editor.text = "Hi\nThis is a long line that span for 3 rows so I can test it.\n\nOk then."
      editor.word_wrap = true
      editor.show_line_numbers = true
      editor.text = "abcde fghijklmnopqrstuvxz 1234567890 abcdefghijklmnopqrstuvxz 1234567890ab the end!"
      cursor = editor.cursor
      Terminal.inject_key_event(key: TextUi::KEY_END)
      ui.process_queued_events
      ui.render
      Terminal.to_s.should eq("1│abcde             \n" \
                              " │fghijklmnopqrstuvx\n" \
                              " │z 1234567890      \n" \
                              " │abcdefghijklmnopqr\n" \
                              " │stuvxz            \n" \
                              " │1234567890ab the  \n" \
                              " │end!              \n")
      cursor.line.should eq(0)
      cursor.col.should eq(83)
      Terminal.cursor.should eq({x: 6, y: 6})

      Terminal.inject_key_event(key: TextUi::KEY_ARROW_UP)
      ui.process_queued_events
      ui.render
      cursor.line.should eq(0)
      cursor.col.should eq(66)
      Terminal.cursor.should eq({x: 6, y: 5})

      Terminal.inject_key_event(key: TextUi::KEY_ARROW_UP)
      ui.process_queued_events
      ui.render
      cursor.line.should eq(0)
      cursor.col.should eq(59)
      Terminal.cursor.should eq({x: 6, y: 4})

      Terminal.inject_key_event(key: TextUi::KEY_ARROW_UP)
      ui.process_queued_events
      ui.render
      cursor.line.should eq(0)
      cursor.col.should eq(41)
      Terminal.cursor.should eq({x: 6, y: 3})

      Terminal.inject_key_event(key: TextUi::KEY_ARROW_UP)
      ui.process_queued_events
      ui.render
      cursor.line.should eq(0)
      cursor.col.should eq(28)
      Terminal.cursor.should eq({x: 6, y: 2})

      Terminal.inject_key_event(key: TextUi::KEY_ARROW_UP)
      ui.process_queued_events
      ui.render
      cursor.line.should eq(0)
      cursor.col.should eq(10)
      Terminal.cursor.should eq({x: 6, y: 1})

      2.times do
        Terminal.inject_key_event(key: TextUi::KEY_ARROW_UP)
        ui.process_queued_events
        ui.render
        cursor.line.should eq(0)
        cursor.col.should eq(4)
        Terminal.cursor.should eq({x: 6, y: 0})
      end

      Terminal.inject_key_event(key: TextUi::KEY_HOME)
      ui.process_queued_events
      ui.render
      cursor.line.should eq(0)
      cursor.col.should eq(0)
      Terminal.cursor.should eq({x: 2, y: 0})

      Terminal.inject_key_event(key: TextUi::KEY_END)
      Terminal.inject_key_event(key: TextUi::KEY_ARROW_DOWN)
      ui.process_queued_events
      ui.render
      cursor.line.should eq(0)
      cursor.col.should eq(83)
      Terminal.cursor.should eq({x: 6, y: 6})
    end
  end

  context "when modifying contents" do
    it "has INSERT mode" do
      ui = init_ui(20, 3)
      editor = TextUi::TextEditor.new(ui, 0, 0, 20, 3)
      editor.text = "12\n34"
      ui.focus(editor)

      Terminal.inject_key_event(key: TextUi::KEY_INSERT)
      ui.process_queued_events
      editor.cursor.insert_mode?.should eq(true)

      Terminal.inject_key_event(key: TextUi::KEY_INSERT)
      ui.process_queued_events
      editor.cursor.insert_mode?.should eq(false)

      Terminal.inject_key_event(key: TextUi::KEY_INSERT)
      Terminal.inject_key_event('A')
      ui.process_queued_events
      ui.render
      Terminal.to_s.should eq("A2                  \n" \
                              "34                  \n" \
                              "~                   \n")

      Terminal.inject_key_event('b')
      Terminal.inject_key_event('c')
      ui.process_queued_events
      ui.render
      Terminal.to_s.should eq("Abc                 \n" \
                              "34                  \n" \
                              "~                   \n")

      Terminal.inject_key_event(key: TextUi::KEY_ENTER)
      Terminal.inject_key_event('d')
      ui.process_queued_events
      ui.render
      Terminal.to_s.should eq("Abc                 \n" \
                              "d                   \n" \
                              "34                  \n")
    end

    it "inserts/deletes letters and lines" do
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

  it "can wrap lines" do
    ui = init_ui(20, 5)
    editor = TextUi::TextEditor.new(ui, 0, 0, 20, 5)
    editor.word_wrap = true
    editor.show_line_numbers = true
    ui.focus(editor)
    editor.open("spec/fixtures/query.sql")
    ui.render
    Terminal.to_s.should eq("1│SELECT column1,   \n" \
                            " │column2           \n" \
                            "2│  FROM fancy_table\n" \
                            "3│  WHERE foo > bar \n" \
                            "~                   \n")

    editor.text = "1234567890123456 78   90"
    ui.render

    Terminal.to_s.should eq("1│1234567890123456  \n" \
                            " │78   90           \n" \
                            "~                   \n" \
                            "~                   \n" \
                            "~                   \n")
    Terminal.inject_key_event(key: TextUi::KEY_DELETE)
    ui.process_queued_events
    ui.render
    Terminal.to_s.should eq("1│234567890123456 78\n" \
                            " │   90             \n" \
                            "~                   \n" \
                            "~                   \n" \
                            "~                   \n")
  end

  pending "can have multiple cursors"
  pending "only render changed lines"
  pending "can select text with keyboard (not sure if termbox and general terminals will handle this)"
  pending "can undo/redo"
  pending "can syntax highlight text"
end
