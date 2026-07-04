# frozen_string_literal: true

require "test_helper"

class TailwindThemeOrderedListTest < Minitest::Test
  def setup
    @theme = StimulusPlumbers::Themes::TailwindTheme.new
  end

  def classes_for(component, **args)
    @theme.resolve(component, **args)[:classes]
  end

  def test_ordered_list_returns_a_classes_string_with_padding
    assert_includes classes_for(:ordered_list), "py-(--sp-space-1)"
  end

  def test_ordered_list_item_returns_a_classes_string
    result = classes_for(:ordered_list_item)

    assert_instance_of String, result
    assert_predicate result, :present?
  end

  def test_ordered_list_item_includes_base_item_classes
    result = classes_for(:ordered_list_item)

    assert_includes result, "flex"
    assert_includes result, "rounded-(--sp-radius-sm)"
  end

  def test_ordered_list_item_includes_aria_current_active_classes
    result = classes_for(:ordered_list_item)

    assert_includes result, "aria-[current]:bg-(--sp-color-primary)/10"
    assert_includes result, "aria-[current]:text-(--sp-color-primary)"
  end

  def test_ordered_list_item_includes_control_base_classes
    result = classes_for(:ordered_list_item)

    assert_includes result, "font-medium"
    assert_includes result, "transition-colors"
    assert_includes result, "disabled:opacity-50"
  end

  def test_ordered_list_item_is_not_cursor_pointer
    refute_includes classes_for(:ordered_list_item), "cursor-pointer"
  end

  def test_ordered_list_item_handle_returns_a_classes_string
    result = classes_for(:ordered_list_item_handle)

    assert_instance_of String, result
    assert_predicate result, :present?
  end

  def test_ordered_list_item_handle_uses_grab_cursor
    result = classes_for(:ordered_list_item_handle)

    assert_includes result, "cursor-grab"
    assert_includes result, "active:cursor-grabbing"
  end

  def test_ordered_list_item_handle_disables_touch_scroll
    assert_includes classes_for(:ordered_list_item_handle), "touch-none"
  end

  def test_ordered_list_item_handle_uses_muted_color
    assert_includes classes_for(:ordered_list_item_handle), "text-(--sp-color-muted-fg)"
  end

  def test_ordered_list_item_content_includes_flex_col
    result = classes_for(:ordered_list_item_content)

    assert_includes result, "flex-col"
    assert_includes result, "flex-1"
  end

  def test_ordered_list_item_title_includes_font_medium
    assert_includes classes_for(:ordered_list_item_title), "font-medium"
  end

  def test_ordered_list_item_description_uses_muted_smaller_text
    result = classes_for(:ordered_list_item_description)

    assert_includes result, "text-(--sp-color-muted-fg)"
    assert_includes result, "text-(length:--sp-text-xs)"
  end
end
