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
    assert_includes result, "focus:ring-2"
    assert_includes result, "focus:ring-(--sp-focus-ring-color)"
    assert_includes result, "focus:outline-none"
    assert_includes result, "cursor-pointer"
    assert_includes result, "disabled:opacity-50"
  end

  def test_form_field_input_checkbox_button_type
    result = classes_for(:form_field_input_checkbox, type: :button)

    assert_includes result, "size-(--sp-control-size)"
    assert_includes result, "shrink-0"
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
    assert_includes result, "[--card-ring:var(--sp-color-muted-fg)]"
    refute_includes result, "focus:ring-(--sp-focus-ring-color)"
  end

  # :form_field_input_radio

  def test_form_field_input_radio_default_type
    result = classes_for(:form_field_input_radio)

    assert_includes result, "size-(--sp-control-size)"
    assert_includes result, "rounded-full"
    assert_includes result, "[accent-color:var(--sp-color-primary)]"
    assert_includes result, "focus:ring-2"
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
    assert_includes result, "peer"
  end

  def test_form_field_input_radio_card_type
    result = classes_for(:form_field_input_radio, type: :card)

    assert_includes result, "hidden"
    assert_includes result, "peer"
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

    assert_includes result, "border-0"
    assert_includes result, "cursor-pointer"
  end

  # :form_field_input_button_clear

  def test_form_field_input_button_clear_includes_base_classes
    result = classes_for(:form_field_input_button_clear)

    assert_includes result, "border-0"
    assert_includes result, "cursor-pointer"
  end
end
