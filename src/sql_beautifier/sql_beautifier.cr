module SQLBeautifier
  INLINE_VERBS     = %w(WITHASC IN COALESCE AS WHEN THEN ELSE END AND UNION ALL ON DISTINCT INTERSECT EXCEPT EXISTS NOT COUNT ROUND CAST).join("\\b|\\b")
  NEW_LINE_VERBS   = "SELECT|FROM|WHERE|CASE|ORDER BY|LIMIT|GROUP BY|(RIGHT |LEFT )*(INNER |OUTER )*JOIN( LATERAL)*|HAVING|OFFSET|UPDATE"
  POSSIBLE_INLINER = /(ORDER BY|CASE)/
  VERBS            = "#{NEW_LINE_VERBS}|#{INLINE_VERBS}"
  STRINGS          = /("[^"]+")|('[^']+')/
  BRACKETS         = "[\\(\\)]"
  SQL_COMMENTS     = /(\s*?--.+\s*)|(\s*?\/\*[^\/\*]*\*\/\s*)/
  COMMENT_CONTENT  = /[\S]+[\s\S]*[\S]+/

  # This code is basically a stripped port of https://github.com/alekseyl/niceql.
  # Some pieces of code were removed to simplify it, some were changed to support queries in lower case,
  # the code removals injected some minor bugs, but this is ok while we don't have a SQL parser to do the job.
  def beautify(sql : String, indentation_base = 2, open_bracket_is_newliner = false) : String
    indent = 0
    first_verb = true
    prev_was_comment = false
    parentness = [] of Bool

    sql = sql.gsub(/(\b#{VERBS}|#{BRACKETS}|#{SQL_COMMENTS})/i) do |verb|
      if verb == "SELECT"
        indent += indentation_base if !open_bracket_is_newliner || parentness.empty? || parentness.last
        parentness[-1] = true unless parentness.last?.nil?
        add_new_line = !first_verb
      elsif verb == "("
        next_closing_bracket = $~.post_match.index(')')
        # check if brackets contains SELECT statement
        add_new_line = open_bracket_is_newliner && !!($~.post_match[0..next_closing_bracket] =~ /SELECT/)
        parentness << add_new_line
      elsif verb == ")"
        # this also covers case when right bracket is used without corresponding left one
        add_new_line = parentness.empty? || parentness.last
        indent -= (parentness.empty? ? 2 * indentation_base : (parentness.last ? indentation_base : 0))
        indent = 0 if indent < 0
        parentness.pop
      elsif verb =~ POSSIBLE_INLINER
        # in postgres ORDER BY can be used in aggregation function this will keep it
        # inline with its agg function
        add_new_line = parentness.empty? || parentness.last
      else
        add_new_line = verb !~ /(#{INLINE_VERBS})/
      end

      # !add_new_line && previous_was_comment means we had newlined comment, and now even
      # if verb is inline verb we will need to add new line with indentation BUT all
      # inliners match with a space before so we need to strip it
      verb = verb.lstrip if !add_new_line && prev_was_comment

      add_new_line = prev_was_comment unless add_new_line
      add_indent = !first_verb && add_new_line

      if verb =~ SQL_COMMENTS
        verb = verb[COMMENT_CONTENT]?.to_s.strip
        prev_was_comment = true
      else
        verb = verb.upcase if verb =~ /\b#{VERBS}\b/i
        first_verb = false
        prev_was_comment = false
      end

      subs = add_indent ? indent_multiline(verb, indent) : verb

      !first_verb && add_new_line ? "\n" + subs : subs
    end
    sql.gsub(/\s+\n/, "\n").strip
  end

  private def indent_multiline(verb, indent)
    if verb =~ /.\s*\n\s*./
      verb.lines.map! { |ln| "#{" " * indent}" + ln }.join("\n")
    else
      "#{" " * indent}" + verb.to_s
    end
  end

  extend self
end
