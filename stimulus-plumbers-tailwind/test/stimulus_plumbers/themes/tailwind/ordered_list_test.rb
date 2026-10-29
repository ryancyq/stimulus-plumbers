# frozen_string_literal: true

require "test_helper"

class TailwindThemeOrderedListTest < Minitest::Test
  include ThemeAssertions

  def setup
    @theme = StimulusPlumbers::Themes::TailwindTheme.new
  end

  def test_ordered_list_item_is_rounded
    assert_includes classes_for(:ordered_list_item), "rounded-(--sp-radius-sm)"
  end

  def test_ordered_list_item_highlights_the_current_item
    result = classes_for(:ordered_list_item)

    assert_includes result, "aria-[current]:bg-(--sp-color-primary)/10"
    assert_includes result, "aria-[current]:text-(--sp-color-primary)"
  end

  def test_ordered_list_item_is_medium_weight_and_dims_when_disabled
    result = classes_for(:ordered_list_item)

    assert_includes result, "font-medium"
    assert_includes result, "disabled:opacity-50"
  end

  def test_ordered_list_item_is_not_cursor_pointer
    refute_includes classes_for(:ordered_list_item), "cursor-pointer"
  end

  def test_ordered_list_item_handle_shows_a_grab_cursor
    result = classes_for(:ordered_list_item_handle)

    assert_includes result, "cursor-grab"
    assert_includes result, "active:cursor-grabbing"
  end

  def test_ordered_list_item_handle_disables_touch_scroll
    assert_includes classes_for(:ordered_list_item_handle), "touch-none"
  end

  def test_ordered_list_item_handle_is_muted
    assert_includes classes_for(:ordered_list_item_handle), "text-(--sp-color-muted-fg)"
  end

  def test_ordered_list_item_title_is_medium_weight
    assert_includes classes_for(:ordered_list_item_title), "font-medium"
  end

  def test_ordered_list_item_description_is_small_muted_text
    result = classes_for(:ordered_list_item_description)

    assert_includes result, "text-(--sp-color-muted-fg)"
    assert_includes result, "text-(length:--sp-text-xs)"
  end
end
