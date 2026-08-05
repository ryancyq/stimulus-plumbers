# frozen_string_literal: true

require "test_helper"

class TailwindThemeFormInputTest < Minitest::Test
  def setup
    @theme = StimulusPlumbers::Themes::TailwindTheme.new
  end

  def classes_for(component, **args)
    @theme.resolve(component, **args)[:classes]
  end

  # :form_field_input

  def test_form_field_input_includes_base_classes
    result = classes_for(:form_field_input)

    assert_includes result, "w-full"
    assert_includes result, "rounded-(--sp-radius-md)"
    assert_includes result, "text-(length:--sp-text-sm)"
  end

  def test_form_field_input_includes_default_border_when_no_error
    assert_includes classes_for(:form_field_input), "border-(--sp-color-muted-fg)"
  end

  def test_form_field_input_excludes_error_border_when_no_error
    refute_includes classes_for(:form_field_input), "border-(--sp-color-error)"
  end

  def test_form_field_input_includes_error_border_when_error
    assert_includes classes_for(:form_field_input, error: true), "border-(--sp-color-error)"
  end

  def test_form_field_input_excludes_default_border_when_error
    refute_includes classes_for(:form_field_input, error: true), "border-(--sp-color-muted-fg)"
  end

  def test_form_field_input_includes_hover_border_when_no_error
    assert_includes classes_for(:form_field_input), "hover:border-(--sp-color-fg)"
  end

  def test_form_field_input_excludes_hover_border_when_error
    refute_includes classes_for(:form_field_input, error: true), "hover:border-(--sp-color-fg)"
  end

  def test_form_field_input_floating_filled_includes_hover_border_when_no_error
    assert_includes classes_for(:form_field_input, floating: :filled), "hover:border-(--sp-color-fg)"
  end

  def test_form_field_input_floating_filled_excludes_hover_border_when_error
    refute_includes classes_for(:form_field_input, floating: :filled, error: true), "hover:border-(--sp-color-fg)"
  end

  # :form_field_input_textarea

  def test_form_field_input_textarea_includes_default_border_when_no_error
    assert_includes classes_for(:form_field_input_textarea), "border-(--sp-color-muted-fg)"
  end

  def test_form_field_input_textarea_includes_error_border_when_error
    assert_includes classes_for(:form_field_input_textarea, error: true), "border-(--sp-color-error)"
  end

  def test_form_field_input_textarea_excludes_default_border_when_error
    refute_includes classes_for(:form_field_input_textarea, error: true), "border-(--sp-color-muted-fg)"
  end

  # :form_field_input_file

  def test_form_field_input_file_includes_default_border_when_no_error
    assert_includes classes_for(:form_field_input_file), "border-(--sp-color-muted-fg)"
  end

  def test_form_field_input_file_includes_error_border_when_error
    assert_includes classes_for(:form_field_input_file, error: true), "border-(--sp-color-error)"
  end

  def test_form_field_input_file_excludes_default_border_when_error
    refute_includes classes_for(:form_field_input_file, error: true), "border-(--sp-color-muted-fg)"
  end

  # :form_field_input_select

  def test_form_field_input_select_includes_default_border_when_no_error
    assert_includes classes_for(:form_field_input_select), "border-(--sp-color-muted-fg)"
  end

  def test_form_field_input_select_includes_error_border_when_error
    assert_includes classes_for(:form_field_input_select, error: true), "border-(--sp-color-error)"
  end

  def test_form_field_input_select_excludes_default_border_when_error
    refute_includes classes_for(:form_field_input_select, error: true), "border-(--sp-color-muted-fg)"
  end

  # :form_field_input_checkbox

  def test_form_field_input_checkbox_default_variant
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

  def test_form_field_input_checkbox_button_type
    result = classes_for(:form_field_input_checkbox, type: :button)

    assert_includes result, "size-(--sp-control-size)"
    assert_includes result, "shrink-0"
    assert_includes result, "[accent-color:var(--sp-color-primary)]"
    refute_includes result, "mt-(--sp-space-4)"
  end

  def test_form_field_input_checkbox_card_type
    result = classes_for(:form_field_input_checkbox, type: :card)

    assert_includes result, "size-(--sp-control-size)"
    assert_includes result, "shrink-0"
    refute_includes result, "mt-(--sp-space-4)"
    refute_includes result, "me-(--sp-space-4)"
  end

  def test_form_field_input_checkbox_card_type_uses_card_ring
    result = classes_for(:form_field_input_checkbox, type: :card)

    assert_includes result, "checked:border-(--card-ring)"
    assert_includes result, "focus:ring-(--card-ring)"
    assert_includes result, "[accent-color:var(--card-ring)]"
    assert_includes result, "[--card-ring:var(--sp-color-muted-fg)]"
    refute_includes result, "focus:ring-(--sp-focus-ring-color)"
  end

  # :form_field_input_radio

  def test_form_field_input_radio_default_type
    result = classes_for(:form_field_input_radio)

    assert_includes result, "size-(--sp-control-size)"
    assert_includes result, "rounded-full"
    assert_includes result, "[accent-color:var(--sp-color-primary)]"
    assert_includes result, "focus:ring-(length:--sp-focus-ring-width)"
    assert_includes result, "focus:ring-(--sp-focus-ring-color)"
    assert_includes result, "focus:outline-none"
    assert_includes result, "cursor-pointer"
    assert_includes result, "disabled:opacity-50"
    refute_includes result, "appearance-none"
    refute_includes result, "checked:border-(--sp-color-primary)"
  end

  def test_form_field_input_radio_button_type
    result = classes_for(:form_field_input_radio, type: :button)

    assert_includes result, "hidden"
    refute_includes result, "peer"
  end

  def test_form_field_input_radio_card_type
    result = classes_for(:form_field_input_radio, type: :card)

    assert_includes result, "hidden"
    refute_includes result, "peer"
  end

  def test_form_field_input_radio_card_type_uses_card_ring
    result = classes_for(:form_field_input_radio, type: :card)

    assert_includes result, "[--card-ring:var(--sp-color-muted-fg)]"
    refute_includes result, "focus:ring-(--sp-focus-ring-color)"
  end

  def test_form_field_input_radio_card_type_respects_variant
    result = classes_for(:form_field_input_radio, type: :card, variant: :success)

    assert_includes result, "[--card-ring:var(--sp-color-success)]"
    refute_includes result, "[--card-ring:var(--sp-color-muted-fg)]"
  end

  def test_form_field_input_radio_button_type_uses_card_ring
    result = classes_for(:form_field_input_radio, type: :button)

    assert_includes result, "[--card-ring:var(--sp-color-muted-fg)]"
  end

  def test_form_field_input_radio_default_type_excludes_card_ring
    refute_includes classes_for(:form_field_input_radio), "--card-ring"
  end

  # :form_field_input_combobox

  def test_form_field_input_combobox_includes_default_border_when_no_error
    assert_includes classes_for(:form_field_input_combobox), "border-(--sp-color-muted-fg)"
  end

  def test_form_field_input_combobox_includes_error_border_when_error
    assert_includes classes_for(:form_field_input_combobox, error: true), "border-(--sp-color-error)"
  end

  def test_form_field_input_combobox_excludes_default_border_when_error
    refute_includes classes_for(:form_field_input_combobox, error: true), "border-(--sp-color-muted-fg)"
  end

  def test_form_field_input_combobox_resets_direct_trigger_input_styles
    result = classes_for(:form_field_input_combobox)

    assert_includes result, "[&>input:not([type=hidden])]:border-0"
    assert_includes result, "[&>input:not([type=hidden])]:rounded-none"
    assert_includes result, "[&>input:not([type=hidden])]:px-0"
    assert_includes result, "[&>input:not([type=hidden])]:py-0"
    assert_includes result, "[&>input:not([type=hidden])]:bg-transparent"
    assert_includes result, "[&>input:not([type=hidden])]:shadow-none"
    assert_includes result, "[&>input:not([type=hidden])]:focus:ring-0"
    refute_includes result, "sp-form-combobox"
  end

  def test_form_field_input_combobox_resets_trigger_group_div_styles
    result = classes_for(:form_field_input_combobox)

    assert_includes result, "[&>div:first-child]:border-0"
    assert_includes result, "[&>div:first-child]:rounded-none"
    assert_includes result, "[&>div:first-child]:focus-within:ring-0"
  end

  def test_form_field_input_combobox_floating_includes_floating_input_base
    result = classes_for(:form_field_input_combobox, floating: :outlined)

    assert_includes result, "peer"
    assert_includes result, "w-full"
    assert_includes result, "[&>input:not([type=hidden])]:border-0"
    assert_includes result, "[&>div:first-child]:border-0"
    assert_includes result, "border-(--sp-color-muted-fg)"
    refute_includes result, "border-(--sp-color-error)"
  end

  def test_form_field_input_combobox_floating_error_border
    result = classes_for(:form_field_input_combobox, floating: :outlined, error: true)

    assert_includes result, "border-(--sp-color-error)"
    refute_includes result, "border-(--sp-color-muted-fg)"
  end

  # :form_field_input_reveal

  def test_form_field_input_reveal_resets_child_input_styles
    result = classes_for(:form_field_input_reveal)

    assert_includes result, "[&>input]:border-0"
    assert_includes result, "[&>input]:rounded-none"
    assert_includes result, "[&>input]:bg-transparent"
    assert_includes result, "[&>input]:shadow-none"
    assert_includes result, "[&>input]:focus:ring-0"
    refute_includes result, "sp-form-input-group"
  end

  def test_form_field_input_reveal_accepts_error_arg
    result = classes_for(:form_field_input_reveal, error: true)

    assert_includes result, "[&>input]:border-0"
  end

  # :form_field_input_clearable

  def test_form_field_input_clearable_resets_child_input_styles
    result = classes_for(:form_field_input_clearable)

    assert_includes result, "[&>input]:border-0"
    assert_includes result, "[&>input]:rounded-none"
    assert_includes result, "[&>input]:bg-transparent"
    assert_includes result, "[&>input]:shadow-none"
    assert_includes result, "[&>input]:focus:ring-0"
    refute_includes result, "sp-form-input-group"
  end

  # :form_field_input_button_reveal

  def test_form_field_input_button_reveal_includes_base_classes
    result = classes_for(:form_field_input_button_reveal)

    assert_includes result, "font-medium"
    assert_includes result, "transition-colors"
    assert_includes result, "disabled:opacity-50"
    assert_includes result, "inline-flex"
    assert_includes result, "items-center"
    assert_includes result, "justify-center"
    assert_includes result, "focus-visible:ring-(--sp-focus-ring-color)"
    assert_includes result, "self-stretch"
    assert_includes result, "px-(--sp-space-2)"
    assert_includes result, "border-0"
    assert_includes result, "cursor-pointer"
    assert_includes result, "rounded-(--sp-radius-sm)"
    assert_includes result, "hover:bg-(--sp-color-muted)"
    assert_includes result, "hover:text-(--sp-color-fg)"
  end

  # :form_field_input_button_clear

  def test_form_field_input_button_clear_includes_base_classes
    result = classes_for(:form_field_input_button_clear)

    assert_includes result, "font-medium"
    assert_includes result, "transition-colors"
    assert_includes result, "disabled:opacity-50"
    assert_includes result, "inline-flex"
    assert_includes result, "items-center"
    assert_includes result, "justify-center"
    assert_includes result, "focus-visible:ring-(--sp-focus-ring-color)"
    assert_includes result, "self-stretch"
    assert_includes result, "px-(--sp-space-2)"
    assert_includes result, "border-0"
    assert_includes result, "cursor-pointer"
    assert_includes result, "rounded-(--sp-radius-sm)"
    assert_includes result, "hover:bg-(--sp-color-muted)"
    assert_includes result, "hover:text-(--sp-color-fg)"
  end

  # :input_group (non-floating)

  def test_input_group_includes_base_flex_and_border
    result = classes_for(:input_group)

    assert_includes result, "flex"
    assert_includes result, "items-center"
    assert_includes result, "border"
    assert_includes result, "rounded-(--sp-radius-md)"
  end

  def test_input_group_default_border_color
    result = classes_for(:input_group)

    assert_includes result, "border-(--sp-color-muted-fg)"
    refute_includes result, "border-(--sp-color-error)"
  end

  def test_input_group_error_border_color
    result = classes_for(:input_group, error: true)

    assert_includes result, "border-(--sp-color-error)"
    refute_includes result, "border-(--sp-color-muted-fg)"
  end

  # :input_group (floating)

  def test_input_group_floating_filled_includes_filled_visual
    result = classes_for(:input_group, floating: :filled)

    assert_includes result, "peer"
    assert_includes result, "rounded-t-(--sp-radius-md)"
    assert_includes result, "bg-(--sp-color-bg-muted)"
    assert_includes result, "border-b-2"
    refute_includes result, "rounded-(--sp-radius-md)"
  end

  def test_input_group_floating_outlined_includes_outlined_visual
    result = classes_for(:input_group, floating: :outlined)

    assert_includes result, "peer"
    assert_includes result, "rounded-(--sp-radius-md)"
    assert_includes result, "border"
  end

  def test_input_group_floating_standard_includes_standard_visual
    result = classes_for(:input_group, floating: :standard)

    assert_includes result, "peer"
    assert_includes result, "border-b-2"
    assert_includes result, "border-0"
    refute_includes result, "rounded-(--sp-radius-md)"
  end

  def test_input_group_floating_default_border_includes_focus_within
    result = classes_for(:input_group, floating: :outlined)

    assert_includes result, "border-(--sp-color-muted-fg)"
    assert_includes result, "focus-within:border-(--sp-color-primary)"
    refute_includes result, "border-(--sp-color-error)"
  end

  def test_input_group_floating_error_border
    result = classes_for(:input_group, floating: :outlined, error: true)

    assert_includes result, "border-(--sp-color-error)"
    refute_includes result, "border-(--sp-color-muted-fg)"
    refute_includes result, "focus-within:border-(--sp-color-primary)"
  end

  def test_input_group_floating_excludes_non_floating_border
    result = classes_for(:input_group, floating: :outlined)

    refute_includes result, "border-(--sp-color-muted-fg)\nborder" # no INPUT_GROUP mixed in
    assert_includes result, "peer"
  end

  def test_progress_in_a_form_field_spans_the_field_width
    assert_includes classes_for(:form_field_input_progress), "w-full"
  end

  def test_progress_in_a_form_field_has_no_text_input_chrome
    result = classes_for(:form_field_input_progress)

    refute_includes result, "border"
    refute_includes result, "focus:ring-2"
  end

  def test_range_track_uses_the_same_colors_as_the_progress_bar
    result = classes_for(:form_field_input_range)

    assert_includes result, "bg-(--sp-color-muted)"
    assert_includes result, "--sp-color-primary"
  end

  # A slider is a track and a thumb — none of the text input's box chrome applies.
  def test_range_does_not_inherit_text_input_chrome
    result = classes_for(:form_field_input_range)

    refute_includes result, "px-(--sp-space-3)"
    refute_includes result, "border-(--sp-color-muted-fg)"
  end

  def test_range_fill_is_driven_by_the_progress_percentage
    assert_includes classes_for(:form_field_input_range), "--sp-progress-percent"
  end

  # Tailwind scans source text, so a class broken across a string continuation is silently
  # dropped from the build — the theme still returns it and every other test still passes.
  def test_range_fill_class_appears_contiguously_in_source
    source = File.read(
      File.expand_path("../../../../../lib/stimulus_plumbers/themes/tailwind/form/input.rb", __dir__)
    )

    fill = StimulusPlumbers::Themes::Tailwind::Form::Input::RANGE_FILL

    assert_includes source, fill, "RANGE_FILL must appear on one line or Tailwind will not generate it"
  end

  def test_range_thumb_is_visible_in_both_engines
    result = classes_for(:form_field_input_range)

    assert_includes result, "[&::-webkit-slider-thumb]"
    assert_includes result, "[&::-moz-range-thumb]"
  end

  def test_range_keeps_a_visible_focus_indicator
    assert_includes classes_for(:form_field_input_range), "focus-visible:ring-(--sp-focus-ring-color)"
  end

  def test_range_group_lays_the_input_and_readout_on_one_row
    result = classes_for(:form_field_input_range_group)

    assert_includes result, "flex"
    assert_includes result, "items-center"
  end

  # The readout is outside the input, so the input's own disabled:opacity-50 never reaches it.
  def test_range_readout_dims_with_a_disabled_control
    assert_includes classes_for(:form_field_input_range_group), "[&:has(input:disabled)>span]:opacity-50"
  end

  # Beside the track, so it needs none of the bar readout's overlay positioning.
  def test_range_readout_sits_beside_the_track_not_over_it
    result = classes_for(:form_field_input_range_value)

    refute_includes result, "absolute"
    assert_includes result, "text-(--sp-color-fg)"
  end

  def test_range_readout_does_not_reflow_as_digits_change
    assert_includes classes_for(:form_field_input_range_value), "tabular-nums"
  end
end
