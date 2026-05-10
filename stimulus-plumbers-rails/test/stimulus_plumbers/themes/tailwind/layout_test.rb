# frozen_string_literal: true

require "test_helper"

class TailwindThemeLayoutTest < Minitest::Test
  def setup
    @theme = StimulusPlumbers::Themes::TailwindTheme.new
  end

  def classes_for(component, **args)
    @theme.resolve(component, **args)[:classes]
  end

  def test_divider_returns_a_classes_string_with_border
    result = classes_for(:divider)

    assert_includes result, "border-t"
    assert_includes result, "border-[--sp-color-border]"
  end

  def test_popover_returns_a_classes_string
    result = classes_for(:popover)

    assert_instance_of String, result
    assert_predicate result, :present?
  end

  def test_popover_includes_border_background_and_z_index_classes
    result = classes_for(:popover)

    assert_includes result, "border"
    assert_includes result, "bg-[--sp-color-bg]"
    assert_includes result, "z-[--sp-z-popover]"
  end
end
