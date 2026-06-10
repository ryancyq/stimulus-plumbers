# frozen_string_literal: true

require "test_helper"

class PlumberOptionsThemeTest < Minitest::Test
  def instance
    Class.new { include StimulusPlumbers::Plumber::Options::Theme }.new
  end

  def test_converts_classes_to_class
    result = instance.merge_theme_options({ classes: "btn btn-primary" })

    assert_equal "btn btn-primary", result
  end

  def test_concatenates_class_and_classes_keys
    result = instance.merge_theme_options({ class: "btn", classes: "btn-primary" })

    assert_includes result, "btn"
    assert_includes result, "btn-primary"
  end

  def test_concatenates_class_across_hashes
    result = instance.merge_theme_options(
      { class: "theme-class" },
      { class: "user-class" }
    )

    assert_includes result, "theme-class"
    assert_includes result, "user-class"
  end

  def test_deduplicates_same_class_across_hashes
    result = instance.merge_theme_options({ class: "btn" }, { class: "btn active" })

    assert_equal "btn active", result
  end

  def test_returns_nil_when_no_classes
    result = instance.merge_theme_options({})

    assert_nil result
  end
end
