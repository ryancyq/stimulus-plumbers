# frozen_string_literal: true

require "test_helper"

class TailwindThemeListTest < Minitest::Test
  include ThemeAssertions

  def setup
    @theme = StimulusPlumbers::Themes::TailwindTheme.new
  end

  def test_list_item_is_rounded_with_a_pointer_cursor
    result = classes_for(:list_item)

    assert_includes result, "cursor-pointer"
    assert_includes result, "rounded-(--sp-radius-sm)"
  end

  def test_list_item_highlights_the_current_item
    result = classes_for(:list_item)

    assert_includes result, "aria-[current]:bg-(--sp-color-primary)/10"
    assert_includes result, "aria-[current]:text-(--sp-color-primary)"
  end

  def test_list_item_is_medium_weight_and_dims_when_disabled
    result = classes_for(:list_item)

    assert_includes result, "font-medium"
    assert_includes result, "disabled:opacity-50"
  end

  def test_list_item_text_is_the_foreground_color
    assert_includes classes_for(:list_item), "text-(--sp-color-fg)"
  end

  def test_list_section_title_is_a_small_muted_uppercase_label
    result = classes_for(:list_section_title)

    assert_includes result, "text-(--sp-color-muted-fg)"
    assert_includes result, "font-semibold"
    assert_includes result, "uppercase"
    assert_includes result, "text-(length:--sp-text-xs)"
  end

  def test_list_section_description_is_small_muted_text
    result = classes_for(:list_section_description)

    assert_includes result, "text-(--sp-color-muted-fg)"
    assert_includes result, "text-(length:--sp-text-xs)"
  end

  def test_list_item_title_is_medium_weight
    assert_includes classes_for(:list_item_title), "font-medium"
  end

  def test_list_item_description_is_small_muted_text
    result = classes_for(:list_item_description)

    assert_includes result, "text-(--sp-color-muted-fg)"
    assert_includes result, "text-(length:--sp-text-xs)"
  end

  def test_list_item_icon_strokes_in_the_text_color
    result = classes_for(:list_item_icon)

    assert_includes result, "stroke-current"
  end
end
