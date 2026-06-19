# frozen_string_literal: true

require "test_helper"

class TailwindThemeListTest < Minitest::Test
  def setup
    @theme = StimulusPlumbers::Themes::TailwindTheme.new
  end

  def classes_for(component, **args)
    @theme.resolve(component, **args)[:classes]
  end

  def test_list_returns_a_classes_string_with_padding
    assert_includes classes_for(:list), "py-(--sp-space-1)"
  end

  def test_list_does_not_divide_items
    result = classes_for(:list)

    refute_includes result, "divide-y"
    refute_includes result, "divide-(--sp-color-border)"
  end

  def test_list_item_returns_a_classes_string
    result = classes_for(:list_item)

    assert_instance_of String, result
    assert_predicate result, :present?
  end

  def test_list_item_includes_base_item_classes
    result = classes_for(:list_item)

    assert_includes result, "flex"
    assert_includes result, "cursor-pointer"
    assert_includes result, "rounded-(--sp-radius-sm)"
  end

  def test_list_item_includes_aria_current_active_classes
    result = classes_for(:list_item)

    assert_includes result, "aria-[current]:bg-(--sp-color-primary)/10"
    assert_includes result, "aria-[current]:text-(--sp-color-primary)"
  end

  def test_list_item_includes_control_base_classes
    result = classes_for(:list_item)

    assert_includes result, "font-medium"
    assert_includes result, "transition-colors"
    assert_includes result, "disabled:opacity-50"
  end

  def test_list_item_uses_neutral_default_text
    assert_includes classes_for(:list_item), "text-(--sp-color-fg)"
  end

  def test_list_section_returns_a_classes_string
    result = classes_for(:list_section)

    assert_instance_of String, result
    assert_predicate result, :present?
  end

  def test_list_section_includes_padding
    assert_includes classes_for(:list_section), "py-(--sp-space-2)"
  end

  def test_list_section_title_includes_muted_small_label_classes
    result = classes_for(:list_section_title)

    assert_includes result, "text-(--sp-color-muted-fg)"
    assert_includes result, "font-semibold"
    assert_includes result, "uppercase"
    assert_includes result, "text-(length:--sp-text-xs)"
  end

  def test_list_section_description_includes_muted_text
    result = classes_for(:list_section_description)

    assert_includes result, "text-(--sp-color-muted-fg)"
    assert_includes result, "text-(length:--sp-text-xs)"
    refute_includes result, "uppercase"
  end

  def test_list_item_content_includes_flex_col
    result = classes_for(:list_item_content)

    assert_includes result, "flex-col"
    assert_includes result, "flex-1"
  end

  def test_list_item_title_includes_font_medium
    assert_includes classes_for(:list_item_title), "font-medium"
  end

  def test_list_item_description_uses_muted_smaller_text
    result = classes_for(:list_item_description)

    assert_includes result, "text-(--sp-color-muted-fg)"
    assert_includes result, "text-(length:--sp-text-xs)"
  end

  def test_list_item_icon_includes_size_and_stroke
    result = classes_for(:list_item_icon)

    assert_includes result, "size-(--sp-icon-size-sm)"
    assert_includes result, "stroke-current"
  end
end
