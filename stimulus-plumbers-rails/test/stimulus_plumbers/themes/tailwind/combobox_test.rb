# frozen_string_literal: true

require "test_helper"

class TailwindThemeComboboxTest < Minitest::Test
  def setup
    @theme = StimulusPlumbers::Themes::TailwindTheme.new
  end

  def classes_for(component, **args)
    @theme.resolve(component, **args)[:classes]
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

    assert_includes result, "bg-[--sp-color-primary]/10"
    assert_includes result, "text-[--sp-color-primary]"
  end

  def test_combobox_option_excludes_selected_classes_when_not_selected
    refute_includes classes_for(:combobox_option, selected: false), "bg-[--sp-color-primary]/10"
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

  def test_combobox_option_group_returns_a_classes_string
    result = classes_for(:combobox_option_group)

    assert_instance_of String, result
    assert_predicate result, :present?
  end

  # ── autocomplete ──────────────────────────────────────────────────────────

  def test_combobox_autocomplete_loading_returns_a_classes_string
    result = classes_for(:combobox_autocomplete_loading)

    assert_instance_of String, result
    assert_predicate result, :present?
  end

  def test_combobox_autocomplete_empty_returns_a_classes_string
    result = classes_for(:combobox_autocomplete_empty)

    assert_instance_of String, result
    assert_predicate result, :present?
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
end
