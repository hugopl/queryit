require "./spec_helper"

describe SQLBeautifier do
  it "beautify a simpel query" do
    ugly = " --comment to second query;\n" \
           "SELECT other FROM other_table;"
    beauty = "--comment to second query;\n" \
             "SELECT other\n" \
             "  FROM other_table;"
    SQLBeautifier.beautify(ugly).should eq(beauty)
  end

  it "beautify a more complex query" do
    ugly = "    -- valuable comment first line\n" \
           "SELECT some,\n" \
           "-- valuable comment to inline verb\n" \
           " COUNT(attributes), /* some comment */ CASE WHEN some > 10 THEN '[{\"attr\": 2}]'::jsonb[] ELSE '{}'::jsonb[] END AS combined_attribute, more \n" \
           "-- valuable comment to newline verb\n" \
           "FROM some_table st RIGHT INNER JOIN some_other so ON so.st_id = st.id      \n" \
           "/* multi line with semicolon;\n" \
           "   comment */\n" \
           "WHERE some NOT IN (SELECT other_some FROM other_table WHERE id IN ARRAY[1,2]::bigint[] ) ORDER BY   some GROUP BY some       HAVING 2 > 1;"
    beauty = "-- valuable comment first line\n" \
             "SELECT some,\n" \
             "  -- valuable comment to inline verb\n" \
             "  COUNT(attributes),\n" \
             "  /* some comment */\n" \
             "  CASE WHEN some > 10 THEN '[{\"attr\": 2}]'::jsonb[] ELSE '{}'::jsonb[] END AS combined_attribute, more\n" \
             "  -- valuable comment to newline verb\n" \
             "  FROM some_table st\n" \
             "  RIGHT INNER JOIN some_other so ON so.st_id = st.id\n" \
             "  /* multi line with semicolon;\n" \
             "     comment */\n" \
             "  WHERE some NOT IN (\n" \
             "    SELECT other_some\n" \
             "    FROM other_table\n" \
             "    WHERE id IN ARRAY[1,2]::bigint[]\n" \
             "  )\n" \
             "  ORDER BY   some\n" \
             "  GROUP BY some\n" \
             "  HAVING 2 > 1;"
    # extra spaces after ORDER BY is a bug
    SQLBeautifier.beautify(ugly).should eq(beauty)
  end

  it "beautify lowercase queries" do
    ugly = "select * from 'whatever.nice_table' Where someThing == 42"
    beauty = "SELECT *\n" \
             "FROM 'whatever.nice_table'\n" \
             "WHERE someThing == 42"
    SQLBeautifier.beautify(ugly).should eq(beauty)
  end
end
