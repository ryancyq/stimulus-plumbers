# frozen_string_literal: true

require "test_helper"

class TailwindThemeFormTest < Minitest::Test
  def setup
    @theme = StimulusPlumbers::Themes::TailwindTheme.new
  end

  def classes_for(component, **args)
    @theme.resolve(component, **args)[:classes]
  end

  # :form_group

  def test_form_group_includes_base_flex_classes
    result = classes_for(:form_group)

    assert_includes result, "flex"
    assert_includes result, "gap-(--sp-space-1)"
    assert_includes result, "mb-(--sp-space-3)"
  end

  def test_form_group_stacked_layout_includes_flex_col
    assert_includes classes_for(:form_group, layout: :stacked), "flex-col"
  end

  def test_form_group_stacked_layout_excludes_inline_classes
    result = classes_for(:form_group, layout: :stacked)

    refute_includes result, "flex-row"
    refute_includes result, "items-center"
  end

  def test_form_group_inline_layout_includes_row_and_alignment_classes
    result = classes_for(:form_group, layout: :inline)

    assert_includes result, "flex-row"
    assert_includes result, "items-center"
  end

  def test_form_group_inline_layout_excludes_flex_col
    refute_includes classes_for(:form_group, layout: :inline), "flex-col"
  end

  # :form_label

  def test_form_label_includes_base_classes
    result = classes_for(:form_label)

    assert_includes result, "text-(length:--sp-text-sm)"
    assert_includes result, "font-medium"
    assert_includes result, "text-(--sp-color-fg)"
  end

  def test_form_label_hidden_includes_sr_only
    assert_includes classes_for(:form_label, hidden: true), "sr-only"
  end

  def test_form_label_not_hidden_excludes_sr_only
    refute_includes classes_for(:form_label, hidden: false), "sr-only"
  end

  # :form_required_mark

  def test_form_required_mark_includes_base_classes
    result = classes_for(:form_required_mark)

    assert_includes result, "text-(--sp-color-error)"
    assert_includes result, "ml-(--sp-space-0-5)"
  end

  # :form_details

  def test_form_details_includes_base_classes
    result = classes_for(:form_details)

    assert_includes result, "text-(length:--sp-text-xs)"
    assert_includes result, "text-(--sp-color-muted-fg)"
  end

  # :form_error

  def test_form_error_includes_base_classes
    result = classes_for(:form_error)

    assert_includes result, "text-(length:--sp-text-xs)"
    assert_includes result, "text-(--sp-color-error)"
  end

  # :form_input

  def test_form_input_includes_base_classes
    result = classes_for(:form_input)

    assert_includes result, "w-full"
    assert_includes result, "rounded-(--sp-radius-md)"
    assert_includes result, "text-(length:--sp-text-sm)"
  end

  def test_form_input_includes_default_border_when_no_error
    assert_includes classes_for(:form_input), "border-(--sp-color-muted-fg)"
  end

  def test_form_input_excludes_error_border_when_no_error
    refute_includes classes_for(:form_input), "border-(--sp-color-error)"
  end

  def test_form_input_includes_error_border_when_error
    assert_includes classes_for(:form_input, error: true), "border-(--sp-color-error)"
  end

  def test_form_input_excludes_default_border_when_error
    refute_includes classes_for(:form_input, error: true), "border-(--sp-color-muted-fg)"
  end

  # :form_textarea

  def test_form_textarea_includes_default_border_when_no_error
    assert_includes classes_for(:form_textarea), "border-(--sp-color-muted-fg)"
  end

  def test_form_textarea_includes_error_border_when_error
    assert_includes classes_for(:form_textarea, error: true), "border-(--sp-color-error)"
  end

  def test_form_textarea_excludes_default_border_when_error
    refute_includes classes_for(:form_textarea, error: true), "border-(--sp-color-muted-fg)"
  end

  # :form_file

  def test_form_file_includes_default_border_when_no_error
    assert_includes classes_for(:form_file), "border-(--sp-color-muted-fg)"
  end

  def test_form_file_includes_error_border_when_error
    assert_includes classes_for(:form_file, error: true), "border-(--sp-color-error)"
  end

  def test_form_file_excludes_default_border_when_error
    refute_includes classes_for(:form_file, error: true), "border-(--sp-color-muted-fg)"
  end

  # :form_select

  def test_form_select_includes_default_border_when_no_error
    assert_includes classes_for(:form_select), "border-(--sp-color-muted-fg)"
  end

  def test_form_select_includes_error_border_when_error
    assert_includes classes_for(:form_select, error: true), "border-(--sp-color-error)"
  end

  def test_form_select_excludes_default_border_when_error
    refute_includes classes_for(:form_select, error: true), "border-(--sp-color-muted-fg)"
  end

  # :form_checkbox

  def test_form_checkbox_default_variant
    result = classes_for(:form_checkbox)

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

  def test_form_checkbox_button_variant
    result = classes_for(:form_checkbox, variant: :button)

    assert_includes result, "size-(--sp-control-size)"
    assert_includes result, "shrink-0"
    refute_includes result, "mt-(--sp-space-4)"
  end

  def test_form_checkbox_card_variant
    result = classes_for(:form_checkbox, variant: :card)

    assert_includes result, "size-(--sp-control-size)"
    assert_includes result, "shrink-0"
    refute_includes result, "mt-(--sp-space-4)"
    refute_includes result, "me-(--sp-space-4)"
  end

  # :form_checkbox_label

  def test_form_checkbox_label_default_variant
    result = classes_for(:form_checkbox_label)

    assert_includes result, "flex"
    assert_includes result, "items-center"
    assert_includes result, "gap-(--sp-space-2)"
    assert_includes result, "cursor-pointer"
    assert_includes result, "text-(--sp-color-fg)"
  end

  def test_form_checkbox_label_button_variant
    result = classes_for(:form_checkbox_label, variant: :button)

    assert_includes result, "flex"
    assert_includes result, "items-start"
    assert_includes result, "p-(--sp-space-4)"
    assert_includes result, "bg-(--sp-color-bg)"
    assert_includes result, "border-(--sp-color-border)"
    assert_includes result, "rounded-(--sp-radius-md)"
    assert_includes result, "hover:bg-(--sp-color-muted)"
    refute_includes result, "justify-between"
  end

  def test_form_checkbox_label_card_variant
    result = classes_for(:form_checkbox_label, variant: :card)

    assert_includes result, "flex"
    assert_includes result, "justify-between"
    assert_includes result, "items-start"
    assert_includes result, "bg-(--sp-color-bg)"
    assert_includes result, "border-(--sp-color-border)"
    assert_includes result, "rounded-(--sp-radius-md)"
    assert_includes result, "hover:bg-(--sp-color-muted)"
  end

  # :form_radio

  def test_form_radio_default_variant
    result = classes_for(:form_radio)

    assert_includes result, "size-(--sp-control-size)"
    assert_includes result, "rounded-full"
    assert_includes result, "border"
    assert_includes result, "border-(--sp-color-border)"
    assert_includes result, "bg-(--sp-color-muted)"
    assert_includes result, "appearance-none"
    assert_includes result, "checked:border-(--sp-color-primary)"
    assert_includes result, "focus:ring-2"
    assert_includes result, "focus:ring-(--sp-focus-ring-color)"
    assert_includes result, "focus:outline-none"
    assert_includes result, "cursor-pointer"
    assert_includes result, "disabled:opacity-50"
  end

  def test_form_radio_button_variant
    result = classes_for(:form_radio, variant: :button)

    assert_includes result, "hidden"
    assert_includes result, "peer"
  end

  def test_form_radio_card_variant
    result = classes_for(:form_radio, variant: :card)

    assert_includes result, "hidden"
    assert_includes result, "peer"
  end

  # :form_radio_label

  def test_form_radio_label_default_variant
    result = classes_for(:form_radio_label)

    assert_includes result, "flex"
    assert_includes result, "items-center"
    assert_includes result, "gap-(--sp-space-2)"
    assert_includes result, "cursor-pointer"
    assert_includes result, "text-(--sp-color-fg)"
  end

  def test_form_radio_label_button_variant
    result = classes_for(:form_radio_label, variant: :button)

    assert_includes result, "inline-flex"
    assert_includes result, "justify-between"
    assert_includes result, "p-(--sp-space-4)"
    assert_includes result, "bg-(--sp-color-bg)"
    assert_includes result, "border-(--sp-color-border)"
    assert_includes result, "rounded-(--sp-radius-md)"
    assert_includes result, "peer-checked:border-(--sp-color-primary)"
    assert_includes result, "peer-checked:bg-(--sp-color-primary)/10"
    assert_includes result, "peer-checked:text-(--sp-color-fg)"
    assert_includes result, "hover:bg-(--sp-color-muted)"
  end

  def test_form_radio_label_card_variant
    result = classes_for(:form_radio_label, variant: :card)

    assert_includes result, "flex"
    assert_includes result, "flex-col"
    assert_includes result, "items-start"
    assert_includes result, "shadow-(--sp-shadow-xs)"
    assert_includes result, "peer-checked:border-(--sp-color-primary)"
    assert_includes result, "peer-checked:bg-(--sp-color-primary)/10"
  end

  # :form_choice_items

  def test_form_choice_items_stacked_layout
    result = classes_for(:form_choice_items)

    assert_includes result, "flex"
    assert_includes result, "flex-col"
    assert_includes result, "gap-(--sp-space-1)"
  end

  def test_form_choice_items_inline_layout
    result = classes_for(:form_choice_items, layout: :inline)

    assert_includes result, "flex"
    assert_includes result, "flex-row"
    assert_includes result, "flex-wrap"
    assert_includes result, "gap-x-(--sp-space-4)"
    assert_includes result, "gap-y-(--sp-space-1)"
  end

  # :form_combobox

  def test_form_combobox_includes_default_border_when_no_error
    assert_includes classes_for(:form_combobox), "border-(--sp-color-muted-fg)"
  end

  def test_form_combobox_includes_error_border_when_error
    assert_includes classes_for(:form_combobox, error: true), "border-(--sp-color-error)"
  end

  def test_form_combobox_excludes_default_border_when_error
    refute_includes classes_for(:form_combobox, error: true), "border-(--sp-color-muted-fg)"
  end

  # :form_input_reveal

  def test_form_input_reveal_includes_marker_class
    assert_includes classes_for(:form_input_reveal), "sp-form-input-group"
  end

  def test_form_input_reveal_accepts_error_arg
    assert_includes classes_for(:form_input_reveal, error: true), "sp-form-input-group"
  end

  # :form_input_clearable

  def test_form_input_clearable_includes_marker_class
    assert_includes classes_for(:form_input_clearable), "sp-form-input-group"
  end

  # :form_button_reveal

  def test_form_button_reveal_includes_base_classes
    result = classes_for(:form_button_reveal)

    assert_includes result, "border-0"
    assert_includes result, "cursor-pointer"
  end

  # :form_button_clear

  def test_form_button_clear_includes_base_classes
    result = classes_for(:form_button_clear)

    assert_includes result, "border-0"
    assert_includes result, "cursor-pointer"
  end

  # :form_submit

  def test_form_submit_default_variant_includes_link_classes
    result = classes_for(:form_submit)

    assert_includes result, "cursor-pointer"
    assert_includes result, "hover:underline"
  end

  def test_form_submit_default_variant_excludes_button_layout_classes
    refute_includes classes_for(:form_submit), "inline-flex"
  end

  def test_form_submit_button_variant_includes_button_layout_classes
    assert_includes classes_for(:form_submit, variant: :button), "inline-flex"
  end

  def test_form_submit_button_variant_excludes_link_classes
    refute_includes classes_for(:form_submit, variant: :button), "hover:underline"
  end
end
