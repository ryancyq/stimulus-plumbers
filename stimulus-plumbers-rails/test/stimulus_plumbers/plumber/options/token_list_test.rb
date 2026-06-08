# frozen_string_literal: true

require "test_helper"

class PlumberOptionsTokenListTest < Minitest::Test
  def instance
    Class.new { include StimulusPlumbers::Plumber::Options::TokenList }.new
  end

  # ── String inputs ─────────────────────────────────────────────────────────────

  def test_string_splits_on_delimiter
    assert_equal "foo bar", instance.merge_token_list("foo bar")
  end

  def test_blank_string_part_excluded
    assert_equal "foo", instance.merge_token_list("", "foo")
  end

  def test_nil_part_excluded
    assert_equal "foo", instance.merge_token_list(nil, "foo")
  end

  # ── Hash inputs ───────────────────────────────────────────────────────────────

  def test_hash_includes_truthy_keys
    assert_equal "active", instance.merge_token_list({ "active" => true, "disabled" => false })
  end

  # ── Array inputs ──────────────────────────────────────────────────────────────

  def test_array_part_recursively_merged
    assert_equal "foo bar", instance.merge_token_list(%w[foo bar])
  end

  def test_empty_array_part_excluded
    assert_equal "foo", instance.merge_token_list([], "foo")
  end

  # ── Other ─────────────────────────────────────────────────────────────────────

  def test_unknown_type_excluded
    assert_equal "", instance.merge_token_list(42)
  end

  def test_deduplicates_tokens_across_parts
    assert_equal "foo bar", instance.merge_token_list("foo", "foo bar")
  end

  def test_custom_delimiter
    assert_equal "a,b", instance.merge_token_list("a", "b", delimiter: ",")
  end
end
