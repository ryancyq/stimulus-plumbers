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

  def test_form_checkbox_button_type
    result = classes_for(:form_checkbox, type: :button)

    assert_includes result, "size-(--sp-control-size)"
    assert_includes result, "shrink-0"
    refute_includes result, "mt-(--sp-space-4)"
  end

  def test_form_checkbox_card_type
    result = classes_for(:form_checkbox, type: :card)

    assert_includes result, "size-(--sp-control-size)"
    assert_includes result, "shrink-0"
    refute_includes result, "mt-(--sp-space-4)"
    refute_includes result, "me-(--sp-space-4)"
  end

  # :form_checkbox_label

  def test_form_checkbox_label_default_type
    result = classes_for(:form_checkbox_label)

    assert_includes result, "flex"
    assert_includes result, "items-center"
    assert_includes result, "gap-(--sp-space-2)"
    assert_includes result, "cursor-pointer"
    assert_includes result, "text-(--sp-color-fg)"
  end

  def test_form_checkbox_label_button_type
    result = classes_for(:form_checkbox_label, type: :button)

    assert_includes result, "flex"
    assert_includes result, "items-center"
    assert_includes result, "p-(--sp-space-4)"
    assert_includes result, "bg-(--sp-color-bg)"
    assert_includes result, "border-(--sp-color-border)"
    assert_includes result, "rounded-(--sp-radius-md)"
    assert_includes result, "hover:bg-(--sp-color-muted)"
    refute_includes result, "items-start"
    refute_includes result, "justify-between"
  end

  def test_form_checkbox_label_card_type
    result = classes_for(:form_checkbox_label, type: :card)

    assert_includes result, "flex"
    assert_includes result, "justify-between"
    assert_includes result, "items-start"
    assert_includes result, "bg-(--sp-color-bg)"
    assert_includes result, "border-(--sp-color-border)"
    assert_includes result, "rounded-(--sp-radius-md)"
    assert_includes result, "hover:bg-(--sp-color-muted)"
    assert_includes result, "hover:border-(--sp-color-border-strong)"
    assert_includes result, "hover:text-(--sp-color-fg)"
    assert_includes result, "has-[:checked]:border-(--card-ring)"
    assert_includes result, "has-[:checked]:bg-(--card-ring)/10"
    assert_includes result, "[--card-ring:var(--sp-color-primary)]"
  end

  def test_form_checkbox_label_card_type_with_variant
    result = classes_for(:form_checkbox_label, type: :card, variant: :success)

    assert_includes result, "[--card-ring:var(--sp-color-success)]"
    refute_includes result, "[--card-ring:var(--sp-color-primary)]"
  end

  def test_form_checkbox_label_non_card_type_ignores_variant
    result = classes_for(:form_checkbox_label, type: :default, variant: :success)

    refute_includes result, "--card-ring"
  end

  def test_form_checkbox_card_type_input
    result = classes_for(:form_checkbox, type: :card)

    assert_includes result, "checked:border-(--card-ring)"
    assert_includes result, "focus:ring-(--card-ring)"
    assert_includes result, "[--card-ring:var(--sp-color-primary)]"
    refute_includes result, "focus:ring-(--sp-focus-ring-color)"
  end

  # :form_radio

  def test_form_radio_default_type
    result = classes_for(:form_radio)

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

  def test_form_radio_button_type
    result = classes_for(:form_radio, type: :button)

    assert_includes result, "hidden"
    assert_includes result, "peer"
  end

  def test_form_radio_card_type
    result = classes_for(:form_radio, type: :card)

    assert_includes result, "hidden"
    assert_includes result, "peer"
  end

  # :form_radio_label

  def test_form_radio_label_default_type
    result = classes_for(:form_radio_label)

    assert_includes result, "flex"
    assert_includes result, "items-center"
    assert_includes result, "gap-(--sp-space-2)"
    assert_includes result, "cursor-pointer"
    assert_includes result, "text-(--sp-color-fg)"
  end

  def test_form_radio_label_button_type
    result = classes_for(:form_radio_label, type: :button)

    assert_includes result, "inline-flex"
    assert_includes result, "justify-between"
    assert_includes result, "p-(--sp-space-4)"
    assert_includes result, "bg-(--sp-color-bg)"
    assert_includes result, "border-(--sp-color-border)"
    assert_includes result, "rounded-(--sp-radius-md)"
    assert_includes result, "peer-checked:border-(--card-ring)"
    assert_includes result, "peer-checked:bg-(--card-ring)/10"
    assert_includes result, "peer-checked:text-(--sp-color-fg)"
    assert_includes result, "hover:bg-(--sp-color-muted)"
    assert_includes result, "[--card-ring:var(--sp-color-primary)]"
  end

  def test_form_radio_label_button_type_with_variant
    result = classes_for(:form_radio_label, type: :button, variant: :destructive)

    assert_includes result, "[--card-ring:var(--sp-color-destructive)]"
    refute_includes result, "[--card-ring:var(--sp-color-primary)]"
  end

  def test_form_radio_label_card_type
    result = classes_for(:form_radio_label, type: :card)

    assert_includes result, "flex"
    refute_includes result, "flex-col"
    assert_includes result, "items-start"
    assert_includes result, "shadow-(--sp-shadow-xs)"
    assert_includes result, "hover:border-(--sp-color-border-strong)"
    assert_includes result, "hover:text-(--sp-color-fg)"
    assert_includes result, "peer-checked:border-(--card-ring)"
    assert_includes result, "peer-checked:bg-(--card-ring)/10"
    assert_includes result, "[--card-ring:var(--sp-color-primary)]"
  end

  def test_form_radio_label_card_type_with_variant
    result = classes_for(:form_radio_label, type: :card, variant: :destructive)

    assert_includes result, "[--card-ring:var(--sp-color-destructive)]"
    refute_includes result, "[--card-ring:var(--sp-color-primary)]"
  end

  def test_form_radio_label_non_card_type_ignores_variant
    result = classes_for(:form_radio_label, type: :default, variant: :success)

    refute_includes result, "--card-ring"
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

  def test_form_submit_default_type_excludes_button_layout_classes
    refute_includes classes_for(:form_submit), "inline-flex"
  end

  def test_form_submit_button_type_includes_button_layout_classes
    assert_includes classes_for(:form_submit, type: :button), "inline-flex"
  end

  def test_form_submit_button_type_excludes_link_classes
    refute_includes classes_for(:form_submit, type: :button), "hover:underline"
  end

  # :form_floating_input

  def test_form_floating_input_includes_base_classes
    result = classes_for(:form_floating_input, type: :filled)

    assert_includes result, "w-full"
    assert_includes result, "text-(--sp-color-fg)"
    assert_includes result, "appearance-none"
    assert_includes result, "focus:ring-0"
  end

  def test_form_floating_input_filled_includes_type_classes
    result = classes_for(:form_floating_input, type: :filled)

    assert_includes result, "rounded-t-(--sp-radius-md)"
    assert_includes result, "bg-(--sp-color-bg-muted)"
    assert_includes result, "border-b-2"
    assert_includes result, "border-0"
  end

  def test_form_floating_input_outlined_includes_type_classes
    result = classes_for(:form_floating_input, type: :outlined)

    assert_includes result, "rounded-(--sp-radius-md)"
    assert_includes result, "border"
    assert_includes result, "bg-transparent"
  end

  def test_form_floating_input_standard_includes_type_classes
    result = classes_for(:form_floating_input, type: :standard)

    assert_includes result, "px-0"
    assert_includes result, "bg-transparent"
    assert_includes result, "border-b-2"
  end

  def test_form_floating_input_includes_default_border_when_no_error
    assert_includes classes_for(:form_floating_input, type: :filled), "border-(--sp-color-muted-fg)"
  end

  def test_form_floating_input_includes_error_border_when_error
    assert_includes classes_for(:form_floating_input, type: :filled, error: true), "border-(--sp-color-error)"
  end

  def test_form_floating_input_excludes_default_border_when_error
    refute_includes classes_for(:form_floating_input, type: :filled, error: true), "border-(--sp-color-muted-fg)"
  end

  # :form_floating_group

  def test_form_floating_group_filled_includes_relative_class
    assert_includes classes_for(:form_floating_group, type: :filled), "relative"
  end

  def test_form_floating_group_outlined_includes_relative_class
    assert_includes classes_for(:form_floating_group, type: :outlined), "relative"
  end

  def test_form_floating_group_standard_includes_z_index_class
    result = classes_for(:form_floating_group, type: :standard)

    assert_includes result, "relative"
    assert_includes result, "z-0"
  end

  # :form_floating_label

  def test_form_floating_label_includes_base_classes
    result = classes_for(:form_floating_label, type: :filled)

    assert_includes result, "absolute"
    assert_includes result, "text-(--sp-color-muted-fg)"
    assert_includes result, "duration-300"
    assert_includes result, "transform"
  end

  def test_form_floating_label_filled_includes_peer_placeholder_classes
    result = classes_for(:form_floating_label, type: :filled)

    assert_includes result, "peer-placeholder-shown:scale-100"
    assert_includes result, "peer-focus:scale-75"
  end

  def test_form_floating_label_outlined_includes_peer_placeholder_classes
    result = classes_for(:form_floating_label, type: :outlined)

    assert_includes result, "peer-placeholder-shown:scale-100"
    assert_includes result, "peer-focus:scale-75"
  end

  def test_form_floating_label_standard_includes_peer_placeholder_classes
    result = classes_for(:form_floating_label, type: :standard)

    assert_includes result, "peer-placeholder-shown:scale-100"
    assert_includes result, "peer-focus:scale-75"
  end

  def test_form_floating_label_includes_focus_color_when_no_error
    assert_includes classes_for(:form_floating_label, type: :filled), "peer-focus:text-(--sp-color-primary)"
  end

  def test_form_floating_label_includes_error_color_when_error
    assert_includes classes_for(:form_floating_label, type: :filled, error: true), "text-(--sp-color-error)"
  end

  def test_form_floating_label_excludes_focus_color_when_error
    refute_includes classes_for(:form_floating_label, type: :filled, error: true),
                    "peer-focus:text-(--sp-color-primary)"
  end
end
