require "./sql_syntaxhighlighter"

class QueryControl
  def initialize(ui : TextUi::Ui)
    @query_box = TextUi::Box.new(ui, "Query", "F2")
    @query_box.border_style = TextUi::Box::BorderStyle::Fancy
    @editor = TextUi::TextEditor.new(@query_box, 1, 1, 0, 0)
    @editor.syntax_highlighter = SQLSyntaxHighlighter.new
    @editor.tab_width = 0
    @editor.show_line_numbers = true
    @editor.word_wrap = true
    @editor.key_typed.on(&->on_key_typed(TextUi::KeyEvent))
    ui.focus(@editor)

    @dbs_box = TextUi::Box.new(ui, "Databases", "F3")
    @dbs_box.border_style = TextUi::Box::BorderStyle::Fancy
    @dbs_list = TextUi::List.new(@dbs_box, 1, 1)
    @dbs_list.width = 18
  end

  def focusable_widgets
    [@editor, @dbs_list]
  end

  def focus_editor
    @editor.focus
  end

  def focus_database_list
    @dbs_list.focus
  end

  def query
    @editor.text
  end

  def query=(sql)
    @editor.text = sql
  end

  def on_database_selected=(proc)
    @dbs_list.on_select = proc
  end

  def available_databases=(databases)
    @dbs_list.items = databases
  end

  def selected_database=(database)
    @dbs_list.select(database)
  end

  def handle_resize(width, height)
    @query_box.width = width - 19
    @query_box.height = height//2
    @editor.width = @query_box.width - 2
    @editor.height = @query_box.height - 2

    @dbs_box.width = 20
    @dbs_box.height = height//2
    @dbs_box.right_of(@query_box)
    @dbs_list.height = @dbs_box.height - 2
  end

  def on_key_typed(event : TextUi::KeyEvent)
    case event.key
    when TextUi::KEY_CTRL_L     then self.query = ""
    when TextUi::KEY_CTRL_SLASH then comment_current_line
    else
      # Key not handled
    end
  end

  private def comment_current_line
    @editor.cursors.each do |cursor|
      block = cursor.current_block
      text = block.text
      if text.starts_with?("-- ")
        block.text = block.text[3..-1]
        cursor.col -= 3
      elsif text.starts_with?("--")
        block.text = block.text[2..-1]
        cursor.col -= 2
      else
        block.text = block.text.insert(0, "-- ")
        cursor.col += 3
      end
    end
  end
end
