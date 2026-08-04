# frozen_string_literal: true

require_relative "../../test_helper"

class DocsTableParserTest < Minitest::Test
  def parse(table)
    StimulusPlumbers::MCP::DocsTableParser.call("## Heading\n\n#{table}")
  end

  def first_option(table)
    parse(table)[:helpers].first[:options].first
  end

  def test_reads_default_and_description_from_three_column_table
    option = first_option(<<~MD)
      | Option  | Default | Description  |
      | ------- | ------- | ------------ |
      | `size:` | `:md`   | Control size |
    MD

    assert_equal "size", option[:option]
    assert_equal ":md", option[:default]
    assert_equal "Control size", option[:description]
  end

  def test_skips_the_values_column_when_default_comes_fourth
    option = first_option(<<~MD)
      | Option     | Values        | Default   | Description |
      | ---------- | ------------- | --------- | ----------- |
      | `variant:` | `:a` \\| `:b` | `:a`      | Which one   |
    MD

    assert_equal ":a", option[:default]
    assert_equal "Which one", option[:description]
  end

  def test_leaves_default_empty_when_the_table_has_no_default_column
    option = first_option(<<~MD)
      | Option  | Description  |
      | ------- | ------------ |
      | `icon:` | Icon to show |
    MD

    assert_equal "", option[:default]
    assert_equal "Icon to show", option[:description]
  end

  def test_reads_default_from_the_named_column_not_its_position
    option = first_option(<<~MD)
      | Option  | Type     | Default | Description |
      | ------- | -------- | ------- | ----------- |
      | `hint:` | String   | `nil`   | Hint text   |
    MD

    assert_equal "nil", option[:default]
    refute_equal "String", option[:default]
  end
end
