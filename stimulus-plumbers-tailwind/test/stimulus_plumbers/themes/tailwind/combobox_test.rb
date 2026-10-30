# frozen_string_literal: true

require "test_helper"

class TailwindThemeComboboxTest < Minitest::Test
  def setup
    @theme = StimulusPlumbers::Themes::TailwindTheme.new
  end

  def classes_for(component, **args)
    @theme.resolve(component, **args)[:classes]
  end

  # ── container ─────────────────────────────────────────────────────────────

  def test_combobox_returns_relative_positioning_class
    assert_includes classes_for(:combobox), "relative"
  end

  # ── popover ───────────────────────────────────────────────────────────────

  def test_each_combobox_popover_anchors_to_its_field
    %i[combobox_dropdown_popover combobox_typeahead_popover combobox_date_popover combobox_time_popover].each do |key|
      assert_includes classes_for(key), "[&[popover]]:[position-anchor:--sp-field]", key
    end
  end

  # ── trigger ───────────────────────────────────────────────────────────────

  def test_combobox_trigger_includes_base_input_classes
    result = classes_for(:combobox_trigger)

    assert_includes result, "w-full"
    assert_includes result, "rounded-(--sp-radius-md)"
    assert_includes result, "focus:ring-2"
    assert_includes result, "focus:ring-(--sp-focus-ring-color)"
  end

  def test_combobox_trigger_includes_hover_border
    assert_includes classes_for(:combobox_trigger), "hover:border-(--sp-color-fg)"
  end

  # ── trigger group ─────────────────────────────────────────────────────────

  def test_combobox_trigger_keeps_an_input_width_when_empty
    assert_includes classes_for(:combobox_trigger), "min-w-(--sp-combobox-min-size)"
  end

  def test_combobox_trigger_group_includes_flex_layout_classes
    result = classes_for(:combobox_trigger_group)

    assert_includes result, "flex"
    assert_includes result, "items-center"
    assert_includes result, "gap-(--sp-space-2)"
  end

  def test_combobox_trigger_group_resets_the_combobox_control_styles
    result = classes_for(:combobox_trigger_group)

    assert_includes result, "[&>[role=combobox]]:border-0"
    assert_includes result, "[&>[role=combobox]]:rounded-none"
    assert_includes result, "[&>[role=combobox]]:focus:ring-0"
    refute_includes result, "sp-combobox-group"
  end

  def test_combobox_trigger_group_includes_focus_ring_classes
    result = classes_for(:combobox_trigger_group)

    assert_includes result, "focus-within:ring-2"
    assert_includes result, "focus-within:ring-(--sp-focus-ring-color)"
  end

  def test_combobox_trigger_group_includes_hover_border
    assert_includes classes_for(:combobox_trigger_group), "hover:border-(--sp-color-fg)"
  end

  # ── listbox ───────────────────────────────────────────────────────────────

  def test_combobox_listbox_returns_a_classes_string
    result = classes_for(:combobox_listbox)

    assert_instance_of String, result
    assert_predicate result, :present?
  end

  def test_combobox_listbox_includes_overflow_class
    assert_includes classes_for(:combobox_listbox), "overflow-y-auto"
  end

  def test_combobox_listbox_includes_min_height_class
    assert_includes classes_for(:combobox_listbox), "min-h-(--sp-space-6)"
  end

  def test_combobox_listbox_collapses_without_a_visible_option
    assert_includes classes_for(:combobox_listbox), "not-has-[[role=option]:not([hidden])]:hidden"
  end

  # ── option ────────────────────────────────────────────────────────────────

  def test_combobox_option_returns_a_classes_string
    result = classes_for(:combobox_option)

    assert_instance_of String, result
    assert_predicate result, :present?
  end

  def test_combobox_option_includes_base_classes
    result = classes_for(:combobox_option)

    assert_includes result, "flex"
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

  def test_combobox_option_includes_disabled_classes_when_disabled
    result = classes_for(:combobox_option, disabled: true)

    assert_includes result, "opacity-50"
    assert_includes result, "cursor-not-allowed"
  end

  def test_combobox_option_excludes_disabled_classes_when_enabled
    refute_includes classes_for(:combobox_option, disabled: false), "opacity-50"
  end

  # ── option group ──────────────────────────────────────────────────────────

  def test_combobox_option_group_includes_padding_class
    assert_includes classes_for(:combobox_option_group), "py-(--sp-space-1)"
  end

  def test_combobox_option_group_label_is_a_muted_heading
    result = classes_for(:combobox_option_group_label)

    assert_includes result, "font-semibold"
    assert_includes result, "text-(--sp-color-muted-fg)"
  end

  # ── status ────────────────────────────────────────────────────────────────

  def test_combobox_status_includes_layout_classes
    result = classes_for(:combobox_status)

    assert_includes result, "flex"
    assert_includes result, "items-center"
    assert_includes result, "justify-center"
  end

  def test_combobox_status_collapses_without_a_message
    assert_includes classes_for(:combobox_status), "empty:hidden"
  end

  # ── time ──────────────────────────────────────────────────────────────────

  def test_combobox_time_returns_a_classes_string
    result = classes_for(:combobox_time)

    assert_instance_of String, result
    assert_predicate result, :present?
  end

  def test_combobox_time_includes_flex_class
    assert_includes classes_for(:combobox_time), "flex"
  end

  # ── time drum ─────────────────────────────────────────────────────────────

  def test_combobox_time_drum_unit_includes_flex_expand_classes
    result = classes_for(:combobox_time_drum, type: :unit)

    assert_includes result, "flex-1"
    assert_includes result, "min-w-0"
    refute_includes result, "shrink-0"
  end

  def test_combobox_time_drum_meridiem_includes_shrink_class
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

  def test_combobox_time_drum_defaults_to_unit_classes
    result = classes_for(:combobox_time_drum)

    assert_includes result, "flex-1"
    assert_includes result, "min-w-0"
  end
end
