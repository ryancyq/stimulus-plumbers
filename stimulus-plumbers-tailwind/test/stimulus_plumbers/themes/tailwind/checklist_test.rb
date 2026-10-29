# frozen_string_literal: true

require "test_helper"

class TailwindThemeChecklistTest < Minitest::Test
  include ThemeAssertions

  def setup
    @theme = StimulusPlumbers::Themes::TailwindTheme.new
  end

  def test_checklist_item_input_shows_the_pointer_cursor
    assert_includes classes_for(:checklist_item_input), "cursor-pointer"
  end

  def test_checklist_item_input_dims_when_disabled
    assert_includes classes_for(:checklist_item_input), "disabled:opacity-50"
  end

  def test_checklist_item_input_checked_color_matches_theme_primary
    assert_includes classes_for(:checklist_item_input), "[accent-color:var(--sp-color-primary)]"
  end

  def test_checklist_item_title_strikes_through_when_checked
    assert_includes classes_for(:checklist_item_title), "group-has-checked/checklist-item:line-through"
  end

  def test_checklist_item_title_is_muted_when_checked
    assert_includes classes_for(:checklist_item_title), "group-has-checked/checklist-item:text-(--sp-color-muted-fg)"
  end

  def test_checklist_item_description_is_small_muted_text
    result = classes_for(:checklist_item_description)

    assert_includes result, "text-(length:--sp-text-xs)"
    assert_includes result, "text-(--sp-color-muted-fg)"
  end

  def test_checklist_item_row_dims_hover_when_disabled
    assert_includes classes_for(:checklist_item), "has-disabled:hover:bg-transparent"
  end
end
