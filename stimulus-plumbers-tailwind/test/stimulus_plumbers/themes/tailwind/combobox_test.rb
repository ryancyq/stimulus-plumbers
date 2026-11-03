# frozen_string_literal: true

require "test_helper"

class TailwindThemeComboboxTest < Minitest::Test
  include ThemeAssertions

  def setup
    @theme = StimulusPlumbers::Themes::TailwindTheme.new
  end

  # ── trigger ───────────────────────────────────────────────────────────────

  def test_combobox_trigger_is_rounded_with_a_focus_ring
    result = classes_for(:combobox_trigger)

    assert_includes result, "rounded-(--sp-radius-md)"
    assert_includes result, "focus:ring-2"
    assert_includes result, "focus:ring-(--sp-focus-ring-color)"
  end

  def test_combobox_trigger_darkens_its_border_on_hover
    assert_includes classes_for(:combobox_trigger), "hover:border-(--sp-color-fg)"
  end

  def test_combobox_trigger_keeps_an_input_width_when_empty
    assert_includes classes_for(:combobox_trigger), "min-w-(--sp-combobox-min-size)"
  end

  # ── trigger group ─────────────────────────────────────────────────────────

  def test_combobox_trigger_group_resets_the_combobox_control_styles
    result = classes_for(:combobox_trigger_group)

    assert_includes result, "[&>[role=combobox]]:border-0"
    assert_includes result, "[&>[role=combobox]]:rounded-none"
    assert_includes result, "[&>[role=combobox]]:focus:ring-0"
  end

  def test_combobox_trigger_group_shows_the_focus_ring_while_focused_within
    result = classes_for(:combobox_trigger_group)

    assert_includes result, "focus-within:ring-2"
    assert_includes result, "focus-within:ring-(--sp-focus-ring-color)"
  end

  def test_combobox_trigger_group_darkens_its_border_on_hover
    assert_includes classes_for(:combobox_trigger_group), "hover:border-(--sp-color-fg)"
  end

  # ── listbox ───────────────────────────────────────────────────────────────

  def test_combobox_listbox_collapses_without_a_visible_option
    assert_includes classes_for(:combobox_listbox), "not-has-[[role=option]:not([hidden])]:hidden"
  end

  # ── option ────────────────────────────────────────────────────────────────

  def test_combobox_option_shows_a_pointer_cursor
    result = classes_for(:combobox_option)

    assert_includes result, "cursor-pointer"
  end

  def test_combobox_option_highlights_whichever_option_is_aria_selected
    result = classes_for(:combobox_option)

    assert_includes result, "aria-selected:bg-(--sp-color-primary)/10"
    assert_includes result, "aria-selected:text-(--sp-color-primary)"
  end

  def test_combobox_option_marks_the_active_option_beyond_color
    result = classes_for(:combobox_option)

    assert_includes result, "aria-selected:outline-2"
    assert_includes result, "aria-selected:outline-(--sp-color-primary)"
  end

  def test_combobox_option_description_is_smaller_muted_text
    result = classes_for(:combobox_option_description)

    assert_includes result, "text-(length:--sp-text-xs)"
    assert_includes result, "text-(--sp-color-muted-fg)"
  end

  def test_combobox_option_dims_and_blocks_the_pointer_when_aria_disabled
    result = classes_for(:combobox_option)

    assert_includes result, "aria-disabled:opacity-50"
    assert_includes result, "aria-disabled:cursor-not-allowed"
  end

  # ── option group ──────────────────────────────────────────────────────────

  def test_combobox_option_group_label_is_a_muted_heading
    result = classes_for(:combobox_option_group_label)

    assert_includes result, "font-semibold"
    assert_includes result, "text-(--sp-color-muted-fg)"
  end

  # ── status ────────────────────────────────────────────────────────────────

  def test_combobox_status_collapses_without_a_message
    assert_includes classes_for(:combobox_status), "empty:hidden"
  end

  # ── time drum ─────────────────────────────────────────────────────────────

  def test_combobox_time_drum_unit_column_shares_the_row_width
    result = classes_for(:combobox_time_drum, type: :unit)

    assert_includes result, "flex-1"
    assert_includes result, "min-w-0"
    refute_includes result, "shrink-0"
  end

  def test_combobox_time_drum_meridiem_column_keeps_its_own_width
    result = classes_for(:combobox_time_drum, type: :meridiem)

    assert_includes result, "shrink-0"
    refute_includes result, "flex-1"
    refute_includes result, "min-w-0"
  end

  def test_every_time_column_shows_keyboard_focus
    %i[unit meridiem].each do |type|
      assert_includes classes_for(:combobox_time_drum, type: type), "focus-visible:ring-(--sp-focus-ring-color)"
    end
  end

  def test_combobox_time_drum_defaults_to_a_unit_column
    assert_equal classes_for(:combobox_time_drum, type: :unit), classes_for(:combobox_time_drum)
  end
end
