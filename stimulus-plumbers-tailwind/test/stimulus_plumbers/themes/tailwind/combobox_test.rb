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

  def test_combobox_popover_includes_absolute_positioning_classes
    result = classes_for(:combobox_popover)

    assert_includes result, "absolute"
    assert_includes result, "top-full"
    assert_includes result, "left-0"
    assert_includes result, "min-w-full"
  end

  # ── trigger ───────────────────────────────────────────────────────────────

  def test_combobox_trigger_includes_base_input_classes
    result = classes_for(:combobox_trigger)

    assert_includes result, "w-full"
    assert_includes result, "rounded-(--sp-radius-md)"
    assert_includes result, "focus:ring-2"
    assert_includes result, "focus:ring-(--sp-focus-ring-color)"
  end

  # ── trigger group ─────────────────────────────────────────────────────────

  def test_combobox_trigger_group_includes_flex_layout_classes
    result = classes_for(:combobox_trigger_group)

    assert_includes result, "flex"
    assert_includes result, "items-center"
    assert_includes result, "gap-(--sp-space-2)"
  end

  def test_combobox_trigger_group_resets_child_input_styles
    result = classes_for(:combobox_trigger_group)

    assert_includes result, "[&>input]:border-0"
    assert_includes result, "[&>input]:rounded-none"
    assert_includes result, "[&>input]:focus:ring-0"
    refute_includes result, "sp-combobox-group"
  end

  def test_combobox_trigger_group_includes_focus_ring_classes
    result = classes_for(:combobox_trigger_group)

    assert_includes result, "focus-within:ring-2"
    assert_includes result, "focus-within:ring-(--sp-focus-ring-color)"
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

  def test_combobox_option_includes_selected_classes_when_selected
    result = classes_for(:combobox_option, selected: true)

    assert_includes result, "bg-(--sp-color-primary)/10"
    assert_includes result, "text-(--sp-color-primary)"
  end

  def test_combobox_option_excludes_selected_classes_when_not_selected
    refute_includes classes_for(:combobox_option, selected: false), "bg-(--sp-color-primary)/10"
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

  # ── typeahead ─────────────────────────────────────────────────────────────

  def test_combobox_typeahead_loading_includes_layout_classes
    result = classes_for(:combobox_typeahead_loading)

    assert_includes result, "flex"
    assert_includes result, "items-center"
    assert_includes result, "justify-center"
  end

  def test_combobox_typeahead_empty_includes_layout_classes
    result = classes_for(:combobox_typeahead_empty)

    assert_includes result, "flex"
    assert_includes result, "items-center"
    assert_includes result, "justify-center"
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

  def test_combobox_time_drum_period_includes_shrink_class
    result = classes_for(:combobox_time_drum, type: :period)

    assert_includes result, "shrink-0"
    refute_includes result, "flex-1"
    refute_includes result, "min-w-0"
  end

  def test_combobox_time_drum_defaults_to_unit_classes
    result = classes_for(:combobox_time_drum)

    assert_includes result, "flex-1"
    assert_includes result, "min-w-0"
  end

  # ── date navigation ───────────────────────────────────────────────────────

  def test_combobox_date_navigation_includes_flex_classes
    result = classes_for(:combobox_date_navigation)

    assert_includes result, "flex"
    assert_includes result, "justify-between"
  end

  def test_combobox_date_navigation_navigator_includes_button_classes
    result = classes_for(:combobox_date_navigation_navigator)

    assert_includes result, "inline-flex"
    assert_includes result, "focus-visible:ring-(length:--sp-focus-ring-width)"
    assert_includes result, "disabled:opacity-50"
  end
end
