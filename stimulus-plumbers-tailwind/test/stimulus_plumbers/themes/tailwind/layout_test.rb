# frozen_string_literal: true

require "test_helper"

class TailwindThemeLayoutTest < Minitest::Test
  def setup
    @theme = StimulusPlumbers::Themes::TailwindTheme.new
  end

  def classes_for(component, **args)
    @theme.resolve(component, **args)[:classes]
  end

  def test_divider_separator_includes_all_classes
    result = classes_for(:divider_separator)

    assert_includes result, "border-t"
    assert_includes result, "border-(--sp-color-border)"
    assert_includes result, "my-(--sp-space-1)"
  end

  def test_popover_returns_a_classes_string
    result = classes_for(:popover)

    assert_instance_of String, result
    assert_predicate result, :present?
  end

  def test_popover_includes_all_classes
    result = classes_for(:popover)

    assert_includes result, "rounded-(--sp-radius-lg)"
    assert_includes result, "border"
    assert_includes result, "border-(--sp-color-border)"
    assert_includes result, "bg-(--sp-color-bg)"
    assert_includes result, "shadow-(--sp-shadow-md)"
    assert_includes result, "z-(--sp-z-popover)"
  end

  def test_divider_returns_a_classes_string
    result = classes_for(:divider)

    assert_instance_of String, result
    assert_predicate result, :present?
  end

  def test_divider_includes_flex_and_gap_classes
    result = classes_for(:divider)

    assert_includes result, "flex"
    assert_includes result, "items-center"
    assert_includes result, "gap-(--sp-space-3)"
  end

  def test_divider_label_returns_a_classes_string
    result = classes_for(:divider_label)

    assert_instance_of String, result
    assert_predicate result, :present?
  end

  def test_divider_label_includes_text_and_whitespace_classes
    result = classes_for(:divider_label)

    assert_includes result, "whitespace-nowrap"
    assert_includes result, "font-medium"
  end
end
