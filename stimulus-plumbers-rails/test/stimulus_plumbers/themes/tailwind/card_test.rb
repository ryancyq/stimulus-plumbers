# frozen_string_literal: true

require "test_helper"

class TailwindThemeCardTest < Minitest::Test
  def setup
    @theme = StimulusPlumbers::Themes::TailwindTheme.new
  end

  def classes_for(component, **args)
    @theme.resolve(component, **args)[:classes]
  end

  def test_card_returns_a_classes_string
    result = classes_for(:card)

    assert_instance_of String, result
    assert_predicate result, :present?
  end

  def test_card_includes_border_and_background_classes
    result = classes_for(:card)

    assert_includes result, "border"
    assert_includes result, "bg-[--sp-color-bg]"
    assert_includes result, "rounded-[--sp-radius-lg]"
  end

  def test_card_section_returns_a_classes_string_with_padding
    assert_includes classes_for(:card_section), "p-[--sp-space-6]"
  end
end
