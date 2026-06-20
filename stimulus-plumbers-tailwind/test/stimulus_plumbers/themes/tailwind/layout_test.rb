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

    assert_includes result, "flex-1"
    assert_includes result, "h-px"
    assert_includes result, "border-0"
    assert_includes result, "bg-(--sp-color-border)"
    refute_includes result, "border-t"
  end

  def test_popover_returns_a_classes_string
    result = classes_for(:popover)

    assert_instance_of String, result
    assert_predicate result, :present?
  end

  def test_popover_includes_all_classes
    result = classes_for(:popover)

    assert_includes result, "rounded-(--sp-radius-md)"
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

    assert_includes result, "w-full"
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

  # :popover_wrapper

  def test_popover_wrapper_includes_positioning_classes
    result = classes_for(:popover_wrapper)

    assert_includes result, "relative"
    assert_includes result, "inline-block"
  end

  # :popover_trigger

  def test_popover_trigger_includes_button_layout_classes
    result = classes_for(:popover_trigger)

    assert_includes result, "inline-flex"
    assert_includes result, "items-center"
    assert_includes result, "font-medium"
  end

  def test_popover_trigger_includes_border_and_background
    result = classes_for(:popover_trigger)

    assert_includes result, "border"
    assert_includes result, "border-(--sp-color-border)"
    assert_includes result, "bg-transparent"
  end

  def test_popover_trigger_includes_focus_ring
    result = classes_for(:popover_trigger)

    assert_includes result, "focus-visible:ring-(length:--sp-focus-ring-width)"
    assert_includes result, "focus-visible:ring-(--sp-focus-ring-color)"
  end

  def test_popover_trigger_includes_hover_muted_bg
    assert_includes classes_for(:popover_trigger), "hover:bg-(--sp-color-muted)"
  end

  def test_popover_trigger_includes_height_class
    assert_includes classes_for(:popover_trigger), "h-9"
  end
end
