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

  def test_action_list_item_excludes_active_classes_when_inactive
    refute_includes classes_for(:action_list_item, active: false), "bg-(--sp-color-primary)/10"
  end

  def test_action_list_item_includes_active_classes_when_active
    result = classes_for(:action_list_item, active: true)

    assert_includes result, "bg-(--sp-color-primary)/10"
    assert_includes result, "text-(--sp-color-primary)"
  end

  def test_action_list_section_returns_a_classes_string
    result = classes_for(:action_list_section)

    assert_instance_of String, result
    assert_predicate result, :present?
  end

  def test_action_list_section_includes_padding
    assert_includes classes_for(:action_list_section), "py-(--sp-space-2)"
  end
end
