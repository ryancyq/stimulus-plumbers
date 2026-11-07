# frozen_string_literal: true

require "test_helper"

class TailwindThemeFormInputTest < Minitest::Test
  include ThemeAssertions

  def setup
    @theme = StimulusPlumbers::Themes::TailwindTheme.new
  end

  # :form_field_input

  def test_form_field_input_is_rounded_small_text
    result = classes_for(:form_field_input)

    assert_includes result, "rounded-(--sp-radius-md)"
    assert_includes result, "text-(length:--sp-text-sm)"
  end

  def test_form_field_input_has_the_muted_border_without_an_error
    assert_includes classes_for(:form_field_input), "border-(--sp-color-muted-fg)"
  end

  def test_form_field_input_has_no_error_border_without_an_error
    refute_includes classes_for(:form_field_input), "border-(--sp-color-error)"
  end

  def test_form_field_input_has_the_error_border_with_an_error
    assert_includes classes_for(:form_field_input, error: true), "border-(--sp-color-error)"
  end

  def test_form_field_input_drops_the_muted_border_with_an_error
    refute_includes classes_for(:form_field_input, error: true), "border-(--sp-color-muted-fg)"
  end

  def test_form_field_input_darkens_its_border_on_hover
    assert_includes classes_for(:form_field_input), "hover:border-(--sp-color-fg)"
  end

  def test_form_field_input_keeps_the_error_border_on_hover
    refute_includes classes_for(:form_field_input, error: true), "hover:border-(--sp-color-fg)"
  end

  def test_form_field_input_floating_filled_darkens_its_border_on_hover
    assert_includes classes_for(:form_field_input, floating: :filled), "hover:border-(--sp-color-fg)"
  end

  def test_form_field_input_floating_filled_keeps_the_error_border_on_hover
    refute_includes classes_for(:form_field_input, floating: :filled, error: true), "hover:border-(--sp-color-fg)"
  end

  # :form_field_input (floating)

  def test_form_field_floating_input_has_no_native_appearance_or_focus_ring
    result = classes_for(:form_field_input, floating: :filled)

    assert_includes result, "text-(--sp-color-fg)"
    assert_includes result, "appearance-none"
    assert_includes result, "focus:ring-0"
  end

  def test_form_field_floating_filled_input_is_a_tinted_field_with_an_underline
    result = classes_for(:form_field_input, floating: :filled)

    assert_includes result, "rounded-t-(--sp-radius-md)"
    assert_includes result, "bg-(--sp-color-bg-muted)"
    assert_includes result, "border-b-2"
    assert_includes result, "border-0"
  end

  def test_form_field_floating_outlined_input_is_a_rounded_bordered_field
    result = classes_for(:form_field_input, floating: :outlined)

    assert_includes result, "rounded-(--sp-radius-md)"
    assert_includes result, "border"
    assert_includes result, "bg-transparent"
  end

  def test_form_field_floating_standard_input_is_a_transparent_underlined_field
    result = classes_for(:form_field_input, floating: :standard)

    assert_includes result, "bg-transparent"
    assert_includes result, "border-b-2"
  end

  def test_form_field_floating_input_has_the_muted_border_without_an_error
    assert_includes classes_for(:form_field_input, floating: :filled), "border-(--sp-color-muted-fg)"
  end

  def test_form_field_floating_input_has_the_error_border_with_an_error
    assert_includes classes_for(:form_field_input, floating: :filled, error: true), "border-(--sp-color-error)"
  end

  def test_form_field_floating_input_drops_the_muted_border_with_an_error
    refute_includes classes_for(:form_field_input, floating: :filled, error: true), "border-(--sp-color-muted-fg)"
  end

  # :form_field_input_textarea

  def test_form_field_input_textarea_has_the_muted_border_without_an_error
    assert_includes classes_for(:form_field_input_textarea), "border-(--sp-color-muted-fg)"
  end

  def test_form_field_input_textarea_has_the_error_border_with_an_error
    assert_includes classes_for(:form_field_input_textarea, error: true), "border-(--sp-color-error)"
  end

  def test_form_field_input_textarea_drops_the_muted_border_with_an_error
    refute_includes classes_for(:form_field_input_textarea, error: true), "border-(--sp-color-muted-fg)"
  end

  # :form_field_input_file

  def test_form_field_input_file_has_the_muted_border_without_an_error
    assert_includes classes_for(:form_field_input_file), "border-(--sp-color-muted-fg)"
  end

  def test_form_field_input_file_has_the_error_border_with_an_error
    assert_includes classes_for(:form_field_input_file, error: true), "border-(--sp-color-error)"
  end

  def test_form_field_input_file_drops_the_muted_border_with_an_error
    refute_includes classes_for(:form_field_input_file, error: true), "border-(--sp-color-muted-fg)"
  end

  # :form_field_input_select

  def test_form_field_input_select_has_the_muted_border_without_an_error
    assert_includes classes_for(:form_field_input_select), "border-(--sp-color-muted-fg)"
  end

  def test_form_field_input_select_has_the_error_border_with_an_error
    assert_includes classes_for(:form_field_input_select, error: true), "border-(--sp-color-error)"
  end

  def test_form_field_input_select_drops_the_muted_border_with_an_error
    refute_includes classes_for(:form_field_input_select, error: true), "border-(--sp-color-muted-fg)"
  end

  # :form_field_input_checkbox

  def test_form_field_input_checkbox_is_a_rounded_primary_control
    result = classes_for(:form_field_input_checkbox)

    assert_includes result, "size-(--sp-control-size)"
    assert_includes result, "rounded-(--sp-radius-sm)"
    assert_includes result, "border"
    assert_includes result, "border-(--sp-color-border)"
    assert_includes result, "bg-(--sp-color-muted)"
    assert_includes result, "[accent-color:var(--sp-color-primary)]"
    assert_includes result, "focus:ring-(length:--sp-focus-ring-width)"
    assert_includes result, "focus:ring-(--sp-focus-ring-color)"
    assert_includes result, "focus:outline-none"
    assert_includes result, "cursor-pointer"
    assert_includes result, "disabled:opacity-50"
  end

  def test_form_field_input_checkbox_button_type_is_a_control_sized_primary_check
    result = classes_for(:form_field_input_checkbox, type: :button)

    assert_includes result, "size-(--sp-control-size)"
    assert_includes result, "[accent-color:var(--sp-color-primary)]"
  end

  def test_form_field_input_checkbox_card_type_is_control_sized
    assert_includes classes_for(:form_field_input_checkbox, type: :card), "size-(--sp-control-size)"
  end

  def test_form_field_input_checkbox_card_type_checks_and_focuses_in_the_card_ring
    result = classes_for(:form_field_input_checkbox, type: :card)

    assert_includes result, "checked:border-(--card-ring)"
    assert_includes result, "focus:ring-(--card-ring)"
    assert_includes result, "[accent-color:var(--card-ring)]"
    assert_includes result, "[--card-ring:var(--sp-color-muted-fg)]"
    refute_includes result, "focus:ring-(--sp-focus-ring-color)"
  end

  def test_form_field_input_checkbox_card_type_ring_follows_the_variant
    result = classes_for(:form_field_input_checkbox, type: :card, variant: :success)

    assert_includes result, "[--card-ring:var(--sp-color-success)]"
    refute_includes result, "[--card-ring:var(--sp-color-muted-fg)]"
  end

  # :form_field_input_radio

  def test_form_field_input_radio_default_type_is_a_round_native_primary_control
    result = classes_for(:form_field_input_radio)

    assert_includes result, "size-(--sp-control-size)"
    assert_includes result, "rounded-full"
    assert_includes result, "[accent-color:var(--sp-color-primary)]"
    assert_includes result, "focus:ring-(length:--sp-focus-ring-width)"
    assert_includes result, "focus:ring-(--sp-focus-ring-color)"
    assert_includes result, "focus:outline-none"
    assert_includes result, "cursor-pointer"
    assert_includes result, "disabled:opacity-50"
  end

  def test_form_field_input_radio_button_type_hides_the_native_radio
    result = classes_for(:form_field_input_radio, type: :button)

    assert_includes result, "hidden"
  end

  def test_form_field_input_radio_card_type_hides_the_native_radio
    result = classes_for(:form_field_input_radio, type: :card)

    assert_includes result, "hidden"
  end

  def test_form_field_input_radio_card_type_takes_the_card_ring
    result = classes_for(:form_field_input_radio, type: :card)

    assert_includes result, "[--card-ring:var(--sp-color-muted-fg)]"
    refute_includes result, "focus:ring-(--sp-focus-ring-color)"
  end

  def test_form_field_input_radio_card_type_ring_follows_the_variant
    result = classes_for(:form_field_input_radio, type: :card, variant: :success)

    assert_includes result, "[--card-ring:var(--sp-color-success)]"
    refute_includes result, "[--card-ring:var(--sp-color-muted-fg)]"
  end

  def test_form_field_input_radio_button_type_takes_the_card_ring
    result = classes_for(:form_field_input_radio, type: :button)

    assert_includes result, "[--card-ring:var(--sp-color-muted-fg)]"
  end

  def test_form_field_input_radio_default_type_has_no_card_ring
    refute_class_containing classes_for(:form_field_input_radio), "--card-ring"
  end

  # :form_field_input_combobox

  def test_form_field_input_combobox_has_the_muted_border_without_an_error
    assert_includes classes_for(:form_field_input_combobox), "border-(--sp-color-muted-fg)"
  end

  def test_form_field_input_combobox_has_the_error_border_with_an_error
    assert_includes classes_for(:form_field_input_combobox, error: true), "border-(--sp-color-error)"
  end

  def test_form_field_input_combobox_drops_the_muted_border_with_an_error
    refute_includes classes_for(:form_field_input_combobox, error: true), "border-(--sp-color-muted-fg)"
  end

  def test_form_field_input_combobox_strips_the_trigger_input_chrome
    result = classes_for(:form_field_input_combobox)

    assert_includes result, "[&>input:not([type=hidden])]:border-0"
    assert_includes result, "[&>input:not([type=hidden])]:rounded-none"
    assert_includes result, "[&>input:not([type=hidden])]:bg-transparent"
    assert_includes result, "[&>input:not([type=hidden])]:shadow-none"
    assert_includes result, "[&>input:not([type=hidden])]:focus:ring-0"
  end

  def test_form_field_input_combobox_strips_the_trigger_group_chrome
    result = classes_for(:form_field_input_combobox)

    assert_includes result, "[&>div:first-child]:border-0"
    assert_includes result, "[&>div:first-child]:rounded-none"
    assert_includes result, "[&>div:first-child]:focus-within:ring-0"
  end

  def test_form_field_input_combobox_shows_the_focus_ring_on_the_field
    assert_includes classes_for(:form_field_input_combobox), "focus-within:ring-(--sp-focus-ring-color)"
    refute_includes classes_for(:form_field_input_combobox), "focus-within:ring-(--sp-color-error)"
  end

  def test_form_field_input_combobox_error_focus_ring_is_the_error_color
    result = classes_for(:form_field_input_combobox, error: true)

    assert_includes result, "focus-within:ring-(--sp-color-error)"
    refute_includes result, "focus-within:ring-(--sp-focus-ring-color)"
  end

  def test_form_field_input_combobox_floating_highlights_the_border_on_focus
    assert_includes classes_for(:form_field_input_combobox, floating: :outlined), "focus-within:border-(--sp-color-primary)"
    refute_includes classes_for(:form_field_input_combobox, floating: :outlined, error: true),
                    "focus-within:border-(--sp-color-primary)"
  end

  def test_form_field_input_combobox_floating_draws_the_muted_border_on_the_field
    result = classes_for(:form_field_input_combobox, floating: :outlined)

    assert_includes result, "[&>input:not([type=hidden])]:border-0"
    assert_includes result, "[&>div:first-child]:border-0"
    assert_includes result, "border-(--sp-color-muted-fg)"
    refute_includes result, "border-(--sp-color-error)"
  end

  def test_form_field_input_combobox_floating_has_the_error_border_with_an_error
    result = classes_for(:form_field_input_combobox, floating: :outlined, error: true)

    assert_includes result, "border-(--sp-color-error)"
    refute_includes result, "border-(--sp-color-muted-fg)"
  end

  # :form_field_input_reveal

  def test_form_field_input_reveal_strips_the_inner_input_chrome
    result = classes_for(:form_field_input_reveal)

    assert_includes result, "[&>input]:border-0"
    assert_includes result, "[&>input]:rounded-none"
    assert_includes result, "[&>input]:bg-transparent"
    assert_includes result, "[&>input]:shadow-none"
    assert_includes result, "[&>input]:focus:ring-0"
  end

  # :form_field_input_clearable

  def test_form_field_input_clearable_strips_the_inner_input_chrome
    result = classes_for(:form_field_input_clearable)

    assert_includes result, "[&>input]:border-0"
    assert_includes result, "[&>input]:rounded-none"
    assert_includes result, "[&>input]:bg-transparent"
    assert_includes result, "[&>input]:shadow-none"
    assert_includes result, "[&>input]:focus:ring-0"
  end

  # :form_field_input_button_reveal

  def test_reveal_and_clear_buttons_show_hover_focus_and_disabled_states
    %i[form_field_input_button_reveal form_field_input_button_clear].each do |key|
      result = classes_for(key)

      assert_includes result, "font-medium", key
      assert_includes result, "cursor-pointer", key
      assert_includes result, "rounded-(--sp-radius-sm)", key
      assert_includes result, "hover:bg-(--sp-color-muted)", key
      assert_includes result, "hover:text-(--sp-color-fg)", key
      assert_includes result, "focus-visible:ring-(--sp-focus-ring-color)", key
      assert_includes result, "disabled:opacity-50", key
    end
  end

  # :input_group (non-floating)

  def test_input_group_draws_one_rounded_border
    result = classes_for(:input_group)

    assert_includes result, "border"
    assert_includes result, "rounded-(--sp-radius-md)"
  end

  def test_input_group_has_the_muted_border_without_an_error
    result = classes_for(:input_group)

    assert_includes result, "border-(--sp-color-muted-fg)"
    refute_includes result, "border-(--sp-color-error)"
  end

  def test_input_group_has_the_error_border_with_an_error
    result = classes_for(:input_group, error: true)

    assert_includes result, "border-(--sp-color-error)"
    refute_includes result, "border-(--sp-color-muted-fg)"
  end

  # :input_group (floating)

  def test_input_group_floating_filled_is_a_tinted_field_with_an_underline
    result = classes_for(:input_group, floating: :filled)

    assert_includes result, "rounded-t-(--sp-radius-md)"
    assert_includes result, "bg-(--sp-color-bg-muted)"
    assert_includes result, "border-b-2"
    refute_includes result, "rounded-(--sp-radius-md)"
  end

  def test_input_group_floating_outlined_is_a_rounded_bordered_field
    result = classes_for(:input_group, floating: :outlined)

    assert_includes result, "rounded-(--sp-radius-md)"
    assert_includes result, "border"
  end

  def test_input_group_floating_standard_is_underlined_only
    result = classes_for(:input_group, floating: :standard)

    assert_includes result, "border-b-2"
    assert_includes result, "border-0"
    refute_includes result, "rounded-(--sp-radius-md)"
  end

  def test_input_group_floating_border_turns_primary_on_focus
    result = classes_for(:input_group, floating: :outlined)

    assert_includes result, "border-(--sp-color-muted-fg)"
    assert_includes result, "focus-within:border-(--sp-color-primary)"
    refute_includes result, "border-(--sp-color-error)"
  end

  def test_input_group_floating_keeps_the_error_border_on_focus
    result = classes_for(:input_group, floating: :outlined, error: true)

    assert_includes result, "border-(--sp-color-error)"
    refute_includes result, "border-(--sp-color-muted-fg)"
    refute_includes result, "focus-within:border-(--sp-color-primary)"
  end

  def test_range_track_matches_the_progress_bar_colors
    result = classes_for(:form_field_input_range)

    assert_includes result, "[&::-webkit-slider-runnable-track]:bg-(--sp-color-muted)"
    assert_includes result, "[&::-moz-range-track]:bg-(--sp-color-muted)"
    assert_includes result, "[&::-moz-range-progress]:bg-(--sp-color-primary)"
  end

  def test_range_does_not_inherit_text_input_chrome
    result = classes_for(:form_field_input_range)

    refute_includes result, "border-(--sp-color-muted-fg)"
  end

  def test_range_fill_is_driven_by_the_progress_percentage
    assert_includes classes_for(:form_field_input_range),
                    "[&::-webkit-slider-runnable-track]:bg-[linear-gradient(to_right,var(--sp-color-primary)_0_" \
                    "calc(var(--sp-progress-percent,0)*1%),transparent_0)]"
  end

  def test_range_fill_stays_on_one_source_line_for_tailwind_to_generate_it
    source = File.read(
      File.expand_path("../../../../../lib/stimulus_plumbers/themes/tailwind/form/input.rb", __dir__)
    )

    fill = StimulusPlumbers::Themes::Tailwind::Form::Input::RANGE_FILL

    assert_includes source, fill, "RANGE_FILL must appear on one line or Tailwind will not generate it"
  end

  def test_range_thumb_is_visible_in_both_engines
    result = classes_for(:form_field_input_range)

    assert_includes result, "[&::-webkit-slider-thumb]:bg-(--sp-color-primary)"
    assert_includes result, "[&::-moz-range-thumb]:bg-(--sp-color-primary)"
  end

  def test_range_keeps_a_visible_focus_indicator
    assert_includes classes_for(:form_field_input_range), "focus-visible:ring-(--sp-focus-ring-color)"
  end

  def test_range_readout_dims_with_a_disabled_control
    assert_includes classes_for(:form_field_input_range_container), "[&:has(input:disabled)>span]:opacity-50"
  end

  def test_range_readout_sits_beside_the_track_not_over_it
    result = classes_for(:form_field_input_range_value)

    refute_includes result, "absolute"
    assert_includes result, "text-(--sp-color-fg)"
  end

  def test_range_readout_does_not_reflow_as_digits_change
    assert_includes classes_for(:form_field_input_range_value), "tabular-nums"
  end

  def test_input_group_floating_darkens_its_border_on_hover
    assert_includes classes_for(:input_group, floating: :filled), "hover:border-(--sp-color-fg)"
  end

  def test_input_group_floating_keeps_the_error_border_on_hover
    refute_includes classes_for(:input_group, floating: :filled, error: true), "hover:border-(--sp-color-fg)"
  end
end
