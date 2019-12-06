require "./spec_helper"

class FooHighlighter < TextUi::SyntaxHighlighter
  property blocks_highlighted = [] of Int32

  def initialize(@document : TextUi::TextDocument)
  end

  def highlight_block(block : TextUi::TextBlock)
    block_idx = @document.blocks.index(block)
    return if block_idx.nil?

    @blocks_highlighted << block_idx
    idx = block.text.index("Foo")
    return if idx.nil?

    block.apply_format(idx, idx + 3, TextUi::Format.new(TextUi::Color::Olive))
  end
end

describe TextUi::SyntaxHighlighter do
  it "can highlight words in editor" do
    ui = init_ui(12, 4)
    editor = TextUi::TextEditor.new(ui, 0, 0, 12, 4)
    highlighter = FooHighlighter.new(editor.document)
    editor.syntax_highlighter = highlighter
    highlighter.blocks_highlighted.should eq([0])
    editor.text = "Bar Foo Foo"
    highlighter.blocks_highlighted.should eq([0, 0])
    ui.render
    Terminal.to_s.should eq("Bar Foo Foo \n" \
                            "~           \n" \
                            "~           \n" \
                            "~           \n")
    Terminal.to_s(colors: true).should eq("e000-e000-e000-e000-6000-6000-6000-e000-e000-e000-e000-e000\n" \
                                          "e000-e000-e000-e000-e000-e000-e000-e000-e000-e000-e000-e000\n" \
                                          "e000-e000-e000-e000-e000-e000-e000-e000-e000-e000-e000-e000\n" \
                                          "e000-e000-e000-e000-e000-e000-e000-e000-e000-e000-e000-e000\n")
    highlighter.blocks_highlighted.clear
    # should render lines 0 and 2
    editor.cursor.move(0, 8)
    ui.focus(editor)
    Terminal.inject_key_event(key: TextUi::KEY_ENTER)
    ui.process_queued_events
    ui.render
    Terminal.to_s.should eq("Bar Foo     \n" \
                            "Foo         \n" \
                            "~           \n" \
                            "~           \n")

    highlighter.blocks_highlighted.should eq([0, 1])

    highlighter.blocks_highlighted.clear
    editor.cursor.move(1, 3)
    Terminal.inject_key_event(chr: 'A')
    ui.process_queued_events
    ui.render
    highlighter.blocks_highlighted.should eq([1])
  end
end
