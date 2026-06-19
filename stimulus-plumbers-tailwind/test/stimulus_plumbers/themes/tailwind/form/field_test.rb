# frozen_string_literal: true

require "test_helper"

class TailwindThemeFormFieldTest < Minitest::Test
  def setup
    @theme = StimulusPlumbers::Themes::TailwindTheme.new
  end

  def classes_for(component, **args)
    @theme.resolve(component, **args)[:classes]
  end

  # :form_field_label

  def test_form_field_label_includes_base_classes
    result = classes_for(:form_field_label)

    assert_includes result, "text-(length:--sp-text-sm)"
    assert_includes result, "font-medium"
    assert_includes result, "text-(--sp-color-fg)"
  end

  def test_form_field_label_hidden_includes_sr_only
    assert_includes classes_for(:form_field_label, hidden: true), "sr-only"
  end

  def test_form_field_label_not_hidden_excludes_sr_only
    refute_includes classes_for(:form_field_label, hidden: false), "sr-only"
  end

  # :form_field_required_mark

  def test_form_field_required_mark_includes_base_classes
    result = classes_for(:form_field_required_mark)

    assert_includes result, "text-(--sp-color-error)"
    assert_includes result, "ml-(--sp-space-0-5)"
  end

  # :form_field_hint

  def test_form_field_hint_includes_base_classes
    result = classes_for(:form_field_hint)

    assert_includes result, "text-(length:--sp-text-xs)"
    assert_includes result, "text-(--sp-color-muted-fg)"
  end

  # :form_field_error

  def test_form_field_error_includes_base_classes
    result = classes_for(:form_field_error)

    assert_includes result, "text-(length:--sp-text-xs)"
    assert_includes result, "text-(--sp-color-error)"
  end

  # :form_field_checkbox_label

  def test_form_field_checkbox_label_default_type
    result = classes_for(:form_field_checkbox_label)

    assert_includes result, "flex"
    assert_includes result, "items-center"
    assert_includes result, "gap-(--sp-space-2)"
    assert_includes result, "cursor-pointer"
    assert_includes result, "text-(--sp-color-fg)"
  end

  def test_form_field_checkbox_label_button_type
    result = classes_for(:form_field_checkbox_label, type: :button)

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

  def test_form_field_checkbox_label_card_type
    result = classes_for(:form_field_checkbox_label, type: :card)

    assert_includes result, "flex"
    assert_includes result, "justify-between"
    assert_includes result, "items-center"
    assert_includes result, "gap-(--sp-space-3)"
    assert_includes result, "bg-(--sp-color-bg)"
    assert_includes result, "border-(--sp-color-border)"
    assert_includes result, "rounded-(--sp-radius-md)"
    assert_includes result, "hover:bg-(--sp-color-muted)"
    assert_includes result, "hover:border-(--sp-color-border-strong)"
    assert_includes result, "hover:text-(--sp-color-fg)"
  end

  def test_form_field_checkbox_label_card_type_checked_states
    result = classes_for(:form_field_checkbox_label, type: :card)

    assert_includes result, "has-[:checked]:border-(--card-ring)"
    assert_includes result, "has-[:checked]:bg-(--card-ring)/10"
    assert_includes result, "has-[:checked]:text-(--sp-color-fg)"
    assert_includes result, "has-[:checked]:hover:bg-(--card-ring)/15"
    assert_includes result, "[--card-ring:var(--sp-color-muted-fg)]"
  end

  def test_form_field_checkbox_label_card_type_with_variant
    result = classes_for(:form_field_checkbox_label, type: :card, variant: :success)

    assert_includes result, "[--card-ring:var(--sp-color-success)]"
    refute_includes result, "[--card-ring:var(--sp-color-muted-fg)]"
  end

  def test_form_field_checkbox_label_non_card_type_ignores_variant
    result = classes_for(:form_field_checkbox_label, type: :default, variant: :success)

    refute_includes result, "--card-ring"
  end

  # :form_field_radio_label

  def test_form_field_radio_label_default_type
    result = classes_for(:form_field_radio_label)

    assert_includes result, "flex"
    assert_includes result, "items-center"
    assert_includes result, "gap-(--sp-space-2)"
    assert_includes result, "cursor-pointer"
    assert_includes result, "text-(--sp-color-fg)"
  end

  def test_form_field_radio_label_button_type
    result = classes_for(:form_field_radio_label, type: :button)

    assert_includes result, "inline-flex"
    assert_includes result, "justify-between"
    assert_includes result, "p-(--sp-space-4)"
    assert_includes result, "bg-(--sp-color-bg)"
    assert_includes result, "border-(--sp-color-border)"
    assert_includes result, "rounded-(--sp-radius-md)"
    assert_includes result, "group-has-[:checked]:border-(--card-ring)"
    assert_includes result, "group-has-[:checked]:bg-(--card-ring)/10"
    assert_includes result, "group-has-[:checked]:text-(--sp-color-fg)"
    assert_includes result, "group-has-[:checked]:hover:bg-(--card-ring)/15"
    assert_includes result, "hover:bg-(--sp-color-muted)"
    assert_includes result, "[--card-ring:var(--sp-color-muted-fg)]"
  end

  def test_form_field_radio_label_button_type_with_variant
    result = classes_for(:form_field_radio_label, type: :button, variant: :destructive)

    assert_includes result, "[--card-ring:var(--sp-color-destructive)]"
    refute_includes result, "[--card-ring:var(--sp-color-muted-fg)]"
  end

  def test_form_field_radio_label_card_type
    result = classes_for(:form_field_radio_label, type: :card)

    assert_includes result, "flex"
    refute_includes result, "flex-col"
    assert_includes result, "items-start"
    assert_includes result, "shadow-(--sp-shadow-xs)"
    assert_includes result, "hover:border-(--sp-color-border-strong)"
    assert_includes result, "hover:text-(--sp-color-fg)"
    assert_includes result, "group-has-[:checked]:border-(--card-ring)"
    assert_includes result, "group-has-[:checked]:bg-(--card-ring)/10"
    assert_includes result, "group-has-[:checked]:text-(--sp-color-fg)"
    assert_includes result, "group-has-[:checked]:hover:bg-(--card-ring)/15"
    assert_includes result, "[--card-ring:var(--sp-color-muted-fg)]"
  end

  def test_form_field_radio_label_card_type_with_variant
    result = classes_for(:form_field_radio_label, type: :card, variant: :destructive)

    assert_includes result, "[--card-ring:var(--sp-color-destructive)]"
    refute_includes result, "[--card-ring:var(--sp-color-muted-fg)]"
  end

  def test_form_field_radio_label_non_card_type_ignores_variant
    result = classes_for(:form_field_radio_label, type: :default, variant: :success)

    refute_includes result, "--card-ring"
  end

  # :form_field_input (floating)

  def test_form_field_floating_includes_base_classes
    result = classes_for(:form_field_input, floating: :filled)

    assert_includes result, "w-full"
    assert_includes result, "text-(--sp-color-fg)"
    assert_includes result, "appearance-none"
    assert_includes result, "focus:ring-0"
  end

  def test_form_field_floating_filled_includes_type_classes
    result = classes_for(:form_field_input, floating: :filled)

    assert_includes result, "rounded-t-(--sp-radius-md)"
    assert_includes result, "bg-(--sp-color-bg-muted)"
    assert_includes result, "border-b-2"
    assert_includes result, "border-0"
  end

  def test_form_field_floating_outlined_includes_type_classes
    result = classes_for(:form_field_input, floating: :outlined)

    assert_includes result, "rounded-(--sp-radius-md)"
    assert_includes result, "border"
    assert_includes result, "bg-transparent"
  end

  def test_form_field_floating_standard_includes_type_classes
    result = classes_for(:form_field_input, floating: :standard)

    assert_includes result, "px-0"
    assert_includes result, "bg-transparent"
    assert_includes result, "border-b-2"
  end

  def test_form_field_floating_includes_default_border_when_no_error
    assert_includes classes_for(:form_field_input, floating: :filled), "border-(--sp-color-muted-fg)"
  end

  def test_form_field_floating_includes_error_border_when_error
    assert_includes classes_for(:form_field_input, floating: :filled, error: true), "border-(--sp-color-error)"
  end

  def test_form_field_floating_excludes_default_border_when_error
    refute_includes classes_for(:form_field_input, floating: :filled, error: true), "border-(--sp-color-muted-fg)"
  end

  # :form_field_input_group

  def test_form_field_floating_group_filled_includes_relative_class
    assert_includes classes_for(:form_field_input_group, floating: :filled), "relative"
  end

  def test_form_field_floating_group_outlined_includes_relative_class
    assert_includes classes_for(:form_field_input_group, floating: :outlined), "relative"
  end

  def test_form_field_floating_group_standard_includes_z_index_class
    result = classes_for(:form_field_input_group, floating: :standard)

    assert_includes result, "relative"
    assert_includes result, "z-0"
  end

  # :form_field_label (floating)

  def test_form_field_floating_label_includes_base_classes
    result = classes_for(:form_field_label, floating: :filled)

    assert_includes result, "absolute"
    assert_includes result, "text-(--sp-color-muted-fg)"
    assert_includes result, "duration-300"
    assert_includes result, "transform"
  end

  def test_form_field_floating_label_filled_includes_peer_placeholder_classes
    result = classes_for(:form_field_label, floating: :filled)

    assert_includes result, "peer-placeholder-shown:scale-100"
    assert_includes result, "peer-focus:scale-75"
  end

  def test_form_field_floating_label_outlined_includes_peer_placeholder_classes
    result = classes_for(:form_field_label, floating: :outlined)

    assert_includes result, "peer-placeholder-shown:scale-100"
    assert_includes result, "peer-focus:scale-75"
  end

  def test_form_field_floating_label_standard_includes_peer_placeholder_classes
    result = classes_for(:form_field_label, floating: :standard)

    assert_includes result, "peer-placeholder-shown:scale-100"
    assert_includes result, "peer-focus:scale-75"
  end

  def test_form_field_floating_label_includes_focus_color_when_no_error
    assert_includes classes_for(:form_field_label, floating: :filled), "peer-focus:text-(--sp-color-primary)"
  end

  def test_form_field_floating_label_includes_error_color_when_error
    assert_includes classes_for(:form_field_label, floating: :filled, error: true), "text-(--sp-color-error)"
  end

  def test_form_field_floating_label_excludes_focus_color_when_error
    refute_includes classes_for(:form_field_label, floating: :filled, error: true),
                    "peer-focus:text-(--sp-color-primary)"
  end

  # :form_field_choice_items

  def test_form_field_choice_items_stacked_layout
    result = classes_for(:form_field_choice_items)

    assert_includes result, "flex"
    assert_includes result, "flex-col"
    assert_includes result, "gap-(--sp-space-1)"
  end

  def test_form_field_choice_items_inline_layout
    result = classes_for(:form_field_choice_items, layout: :inline)

    assert_includes result, "flex"
    assert_includes result, "flex-row"
    assert_includes result, "flex-wrap"
    assert_includes result, "gap-x-(--sp-space-4)"
    assert_includes result, "gap-y-(--sp-space-1)"
  end
end
