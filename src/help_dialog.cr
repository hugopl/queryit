class HelpDialog < TextUi::Dialog
  CONTENTS = "                        SQL JOINS CHEATSHEET\n" \
             "       _..----.._  _..----.._         A:\n" \
             "    _-'          '-_         '-_      SELECT * FROM A\n" \
             "  .'           .'   '.          '.      LEFT JOIN B ON A.key = B.key\n" \
             " /            /       \\           \\\n" \
             "|            |         |           |  B:\n" \
             "|      A     |    C    |     B     |  SELECT * FROM B\n" \
             "|            |         |           |    LEFT JOIN A ON B.key = A.key\n" \
             " \\            \\       /           /\n" \
             "  '.           '.   .'          .'    C:\n" \
             "    `-._        _--'_       _.-'      SELECT * FROM A\n" \
             "        `\"----\"`     \"----\"`           INNER JOIN B ON A.key = B.key\n" \
             "                            SHORTCUTS\n" \
             "  CTRL+L    Clear query editor\n" \
             "  CTRL+/    (Un)Comment lines\n" \
             "  CTRL+Z    Undo\n" \
             "  CTRL+Y    Redo\n" \
             "  TAB       Cycle views\n"

  def initialize(ui)
    super(ui, "Queryit v#{VERSION} - Help")
    close_when_lose_focus

    size = TextUi::Widget.text_dimensions(CONTENTS, ui.width - 2, ui.height - 2)
    resize(size[:width] + 2, size[:height] + 2)

    label = TextUi::Label.new(self, 1, 1, CONTENTS)
    label.resize(size[:width], size[:height])
    old_focus = ui.focused_widget
    ui.focus(self)
    dismissed.on { ui.focus(old_focus) }
  end

  def on_key_event(event)
    dismiss
  end
end
