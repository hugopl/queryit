require "./spec_helper"
require "../src/sql_syntaxhighlighter"

describe SQLSyntaxHighlighter do
  it "highlights multiline comments" do
    doc = TextUi::TextDocument.new
    doc.contents = "select /*\nhey\n*/ ho"
    doc.syntax_highlighter = SQLSyntaxHighlighter.new

    doc.blocks[0].formats.should eq([SQLSyntaxHighlighter::KEYWORD_FORMAT,  # S
                                     SQLSyntaxHighlighter::KEYWORD_FORMAT,  # E
                                     SQLSyntaxHighlighter::KEYWORD_FORMAT,  # L
                                     SQLSyntaxHighlighter::KEYWORD_FORMAT,  # E
                                     SQLSyntaxHighlighter::KEYWORD_FORMAT,  # C
                                     SQLSyntaxHighlighter::KEYWORD_FORMAT,  # T
                                     TextUi::Format::DEFAULT,               #
                                     SQLSyntaxHighlighter::COMMENT_FORMAT,  # /
                                     SQLSyntaxHighlighter::COMMENT_FORMAT]) # *

    doc.blocks[1].formats.should eq([SQLSyntaxHighlighter::COMMENT_FORMAT,  # h
                                     SQLSyntaxHighlighter::COMMENT_FORMAT,  # e
                                     SQLSyntaxHighlighter::COMMENT_FORMAT]) # y

    doc.blocks[2].formats.should eq([SQLSyntaxHighlighter::COMMENT_FORMAT, # *
                                     SQLSyntaxHighlighter::COMMENT_FORMAT, # /
                                     TextUi::Format::DEFAULT,              #
                                     TextUi::Format::DEFAULT,              # h
                                     TextUi::Format::DEFAULT])             # o
  end

  it "highlights multiple multiline comments in the same line" do
    doc = TextUi::TextDocument.new
    doc.contents = "/**//**/ /**/ "
    doc.syntax_highlighter = SQLSyntaxHighlighter.new
    doc.blocks[0].formats.should eq([SQLSyntaxHighlighter::COMMENT_FORMAT,
                                     SQLSyntaxHighlighter::COMMENT_FORMAT,
                                     SQLSyntaxHighlighter::COMMENT_FORMAT,
                                     SQLSyntaxHighlighter::COMMENT_FORMAT,
                                     SQLSyntaxHighlighter::COMMENT_FORMAT,
                                     SQLSyntaxHighlighter::COMMENT_FORMAT,
                                     SQLSyntaxHighlighter::COMMENT_FORMAT,
                                     SQLSyntaxHighlighter::COMMENT_FORMAT,
                                     TextUi::Format::DEFAULT,
                                     SQLSyntaxHighlighter::COMMENT_FORMAT,
                                     SQLSyntaxHighlighter::COMMENT_FORMAT,
                                     SQLSyntaxHighlighter::COMMENT_FORMAT,
                                     SQLSyntaxHighlighter::COMMENT_FORMAT,
                                     TextUi::Format::DEFAULT])
  end

  it "finishes multiline comment when reusing block states" do
    doc = TextUi::TextDocument.new
    doc.syntax_highlighter = SQLSyntaxHighlighter.new
    doc.contents = "/*"
    doc.blocks[0].formats.should eq([SQLSyntaxHighlighter::COMMENT_FORMAT,
                                     SQLSyntaxHighlighter::COMMENT_FORMAT])
    doc.blocks[0].text = "/**/"
    doc.insert(1, "Hi")
    doc.blocks[1].formats.should eq([TextUi::Format::DEFAULT,
                                     TextUi::Format::DEFAULT])
  end

  it "re-highlight next lines after a block state change (i.e. closing a multiline comment)" do
    doc = TextUi::TextDocument.new
    doc.syntax_highlighter = SQLSyntaxHighlighter.new
    doc.contents = "/*\nHi\n\n"
    doc.blocks[1].formats.should eq([SQLSyntaxHighlighter::COMMENT_FORMAT,
                                     SQLSyntaxHighlighter::COMMENT_FORMAT])

    doc.blocks[0].text = "/* */"
    doc.blocks[0].formats.should eq([SQLSyntaxHighlighter::COMMENT_FORMAT,
                                     SQLSyntaxHighlighter::COMMENT_FORMAT,
                                     SQLSyntaxHighlighter::COMMENT_FORMAT,
                                     SQLSyntaxHighlighter::COMMENT_FORMAT,
                                     SQLSyntaxHighlighter::COMMENT_FORMAT])
    doc.blocks[1].formats.should eq([TextUi::Format::DEFAULT,
                                     TextUi::Format::DEFAULT])
  end

  it "do highlight SQL like line comments" do
    doc = TextUi::TextDocument.new
    doc.syntax_highlighter = SQLSyntaxHighlighter.new
    doc.contents = " -- hi "
    doc.blocks[0].formats.should eq([TextUi::Format::DEFAULT,
                                     SQLSyntaxHighlighter::COMMENT_FORMAT,
                                     SQLSyntaxHighlighter::COMMENT_FORMAT,
                                     SQLSyntaxHighlighter::COMMENT_FORMAT,
                                     SQLSyntaxHighlighter::COMMENT_FORMAT,
                                     SQLSyntaxHighlighter::COMMENT_FORMAT,
                                     SQLSyntaxHighlighter::COMMENT_FORMAT])
  end

  it "do not highlight SQL like line comments inside strings" do
    doc = TextUi::TextDocument.new
    doc.syntax_highlighter = SQLSyntaxHighlighter.new
    doc.contents = "'-- hi'"
    doc.blocks[0].formats.should eq([SQLSyntaxHighlighter::STRING_FORMAT,
                                     SQLSyntaxHighlighter::STRING_FORMAT,
                                     SQLSyntaxHighlighter::STRING_FORMAT,
                                     SQLSyntaxHighlighter::STRING_FORMAT,
                                     SQLSyntaxHighlighter::STRING_FORMAT,
                                     SQLSyntaxHighlighter::STRING_FORMAT,
                                     SQLSyntaxHighlighter::STRING_FORMAT])
  end

  it "do not highlight SQL like multiline comments inside strings" do
    doc = TextUi::TextDocument.new
    doc.syntax_highlighter = SQLSyntaxHighlighter.new
    doc.contents = "'/* */'"
    doc.blocks[0].formats.should eq([SQLSyntaxHighlighter::STRING_FORMAT,
                                     SQLSyntaxHighlighter::STRING_FORMAT,
                                     SQLSyntaxHighlighter::STRING_FORMAT,
                                     SQLSyntaxHighlighter::STRING_FORMAT,
                                     SQLSyntaxHighlighter::STRING_FORMAT,
                                     SQLSyntaxHighlighter::STRING_FORMAT,
                                     SQLSyntaxHighlighter::STRING_FORMAT])
  end

  it "highlight numbers" do
    doc = TextUi::TextDocument.new
    doc.syntax_highlighter = SQLSyntaxHighlighter.new
    samples = %w(1402 14.2 .123 2e34 1e-3 2E34 1E-3 2e34 1e+3 2E34 1E+3)
    samples.each do |sample|
      doc.contents = sample
      doc.blocks[0].formats.should(eq([SQLSyntaxHighlighter::NUMBER_FORMAT,
                                       SQLSyntaxHighlighter::NUMBER_FORMAT,
                                       SQLSyntaxHighlighter::NUMBER_FORMAT,
                                       SQLSyntaxHighlighter::NUMBER_FORMAT]), "Contents: #{sample.inspect}")
    end
  end
end
