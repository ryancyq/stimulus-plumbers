# frozen_string_literal: true

require "test_helper"

class TailwindThemeActionListTest < Minitest::Test
  def setup
    @theme = StimulusPlumbers::Themes::TailwindTheme.new
  end

  def classes_for(component, **args)
    @theme.resolve(component, **args)[:classes]
  end

  def test_action_list_returns_a_classes_string_with_padding
    assert_includes classes_for(:action_list), "py-(--sp-space-1)"
  end

  def test_action_list_includes_section_divider
    result = classes_for(:action_list)

    assert_includes result, "divide-y"
    assert_includes result, "divide-(--sp-color-border)"
  end

  def test_action_list_item_returns_a_classes_string
    result = classes_for(:action_list_item)

    assert_instance_of String, result
    assert_predicate result, :present?
  end

  def test_action_list_item_includes_base_item_classes
    result = classes_for(:action_list_item)

    assert_includes result, "flex"
    assert_includes result, "cursor-pointer"
    assert_includes result, "rounded-(--sp-radius-sm)"
  end

  def test_action_list_item_includes_aria_current_active_classes
    result = classes_for(:action_list_item)

    assert_includes result, "aria-[current]:bg-(--sp-color-primary)/10"
    assert_includes result, "aria-[current]:text-(--sp-color-primary)"
  end

  def test_action_list_section_returns_a_classes_string
    result = classes_for(:action_list_section)

    assert_instance_of String, result
    assert_predicate result, :present?
  end

  def test_action_list_section_includes_padding
    assert_includes classes_for(:action_list_section), "py-(--sp-space-2)"
  end

  def test_action_list_section_header_returns_a_classes_string
    result = classes_for(:action_list_section_header)

    assert_instance_of String, result
    assert_predicate result, :present?
  end

  def test_action_list_section_header_includes_muted_small_label_classes
    result = classes_for(:action_list_section_header)

    assert_includes result, "text-(--sp-color-muted-fg)"
    assert_includes result, "font-semibold"
    assert_includes result, "uppercase"
    assert_includes result, "text-(length:--sp-text-xs)"
  end

  def test_action_list_item_uses_neutral_default_text
    assert_includes classes_for(:action_list_item), "text-(--sp-color-fg)"
  end

  def test_action_list_item_includes_control_base_classes
    result = classes_for(:action_list_item)

    assert_includes result, "font-medium"
    assert_includes result, "transition-colors"
    assert_includes result, "disabled:opacity-50"
  end
end
