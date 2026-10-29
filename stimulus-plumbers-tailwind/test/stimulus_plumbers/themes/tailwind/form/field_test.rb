# frozen_string_literal: true

require "test_helper"

class TailwindThemeFormFieldTest < Minitest::Test
  include ThemeAssertions

  def setup
    @theme = StimulusPlumbers::Themes::TailwindTheme.new
  end

  # :form_field_label

  def test_form_field_label_is_small_medium_weight_text
    result = classes_for(:form_field_label)

    assert_includes result, "text-(length:--sp-text-sm)"
    assert_includes result, "font-medium"
    assert_includes result, "text-(--sp-color-fg)"
  end

  def test_form_field_label_hidden_is_visually_hidden
    assert_includes classes_for(:form_field_label, hidden: true), "sr-only"
  end

  def test_form_field_label_not_hidden_is_visible
    refute_includes classes_for(:form_field_label, hidden: false), "sr-only"
  end

  # :form_field_required_mark

  def test_form_field_required_mark_is_the_error_color
    assert_includes classes_for(:form_field_required_mark), "text-(--sp-color-error)"
  end

  # :form_field_hint

  def test_form_field_hint_is_small_muted_text
    result = classes_for(:form_field_hint)

    assert_includes result, "text-(length:--sp-text-xs)"
    assert_includes result, "text-(--sp-color-muted-fg)"
  end

  # :form_field_error

  def test_form_field_error_is_small_error_text
    result = classes_for(:form_field_error)

    assert_includes result, "text-(length:--sp-text-xs)"
    assert_includes result, "text-(--sp-color-error)"
  end

  # :form_field_checkbox_label

  def test_form_field_checkbox_label_default_type_is_clickable_foreground_text
    result = classes_for(:form_field_checkbox_label)

    assert_includes result, "cursor-pointer"
    assert_includes result, "text-(--sp-color-fg)"
  end

  def test_form_field_checkbox_label_button_type_is_a_rounded_bordered_surface_that_tints_on_hover
    result = classes_for(:form_field_checkbox_label, type: :button)

    assert_includes result, "bg-(--sp-color-bg)"
    assert_includes result, "border-(--sp-color-border)"
    assert_includes result, "rounded-(--sp-radius-md)"
    assert_includes result, "hover:bg-(--sp-color-muted)"
  end

  def test_form_field_checkbox_label_card_type_is_a_rounded_bordered_surface_with_hover_states
    result = classes_for(:form_field_checkbox_label, type: :card)

    assert_includes result, "bg-(--sp-color-bg)"
    assert_includes result, "border-(--sp-color-border)"
    assert_includes result, "rounded-(--sp-radius-md)"
    assert_includes result, "hover:bg-(--sp-color-muted)"
    assert_includes result, "hover:border-(--sp-color-border-strong)"
    assert_includes result, "hover:text-(--sp-color-fg)"
  end

  def test_form_field_checkbox_label_card_type_tints_in_the_card_ring_when_checked
    result = classes_for(:form_field_checkbox_label, type: :card)

    assert_includes result, "has-[:checked]:border-(--card-ring)"
    assert_includes result, "has-[:checked]:bg-(--card-ring)/10"
    assert_includes result, "has-[:checked]:text-(--sp-color-fg)"
    assert_includes result, "has-[:checked]:hover:bg-(--card-ring)/15"
    assert_includes result, "[--card-ring:var(--sp-color-muted-fg)]"
  end

  def test_form_field_checkbox_label_card_type_ring_follows_the_variant
    result = classes_for(:form_field_checkbox_label, type: :card, variant: :success)

    assert_includes result, "[--card-ring:var(--sp-color-success)]"
    refute_includes result, "[--card-ring:var(--sp-color-muted-fg)]"
  end

  def test_form_field_checkbox_label_default_type_has_no_card_ring
    result = classes_for(:form_field_checkbox_label, type: :default, variant: :success)

    refute_class_containing result, "--card-ring"
  end

  # :form_field_radio_label

  def test_form_field_radio_label_default_type_is_clickable_foreground_text
    result = classes_for(:form_field_radio_label)

    assert_includes result, "cursor-pointer"
    assert_includes result, "text-(--sp-color-fg)"
  end

  def test_form_field_radio_label_button_type_is_a_bordered_surface_that_tints_in_the_card_ring_when_checked
    result = classes_for(:form_field_radio_label, type: :button)

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

  def test_form_field_radio_label_button_type_ring_follows_the_variant
    result = classes_for(:form_field_radio_label, type: :button, variant: :destructive)

    assert_includes result, "[--card-ring:var(--sp-color-destructive)]"
    refute_includes result, "[--card-ring:var(--sp-color-muted-fg)]"
  end

  def test_form_field_radio_label_card_type_is_a_raised_surface_that_tints_in_the_card_ring_when_checked
    result = classes_for(:form_field_radio_label, type: :card)

    assert_includes result, "shadow-(--sp-shadow-xs)"
    assert_includes result, "hover:border-(--sp-color-border-strong)"
    assert_includes result, "hover:text-(--sp-color-fg)"
    assert_includes result, "group-has-[:checked]:border-(--card-ring)"
    assert_includes result, "group-has-[:checked]:bg-(--card-ring)/10"
    assert_includes result, "group-has-[:checked]:text-(--sp-color-fg)"
    assert_includes result, "group-has-[:checked]:hover:bg-(--card-ring)/15"
    assert_includes result, "[--card-ring:var(--sp-color-muted-fg)]"
  end

  def test_form_field_radio_label_card_type_ring_follows_the_variant
    result = classes_for(:form_field_radio_label, type: :card, variant: :destructive)

    assert_includes result, "[--card-ring:var(--sp-color-destructive)]"
    refute_includes result, "[--card-ring:var(--sp-color-muted-fg)]"
  end

  def test_form_field_radio_label_default_type_has_no_card_ring
    result = classes_for(:form_field_radio_label, type: :default, variant: :success)

    refute_class_containing result, "--card-ring"
  end

  # :form_field_input_group

  def test_every_floating_input_group_positions_its_floating_label
    %i[filled outlined standard].each do |floating|
      assert_includes classes_for(:form_field_input_group, floating: floating), "relative", floating
    end
    assert_includes classes_for(:form_field_input_group, floating: :standard), "z-0"
  end

  # :form_field_label (floating)

  def test_form_field_floating_label_is_muted_and_animates
    result = classes_for(:form_field_label, floating: :filled)

    assert_includes result, "text-(--sp-color-muted-fg)"
    assert_includes result, "duration-300"
    assert_includes result, "transform"
  end

  def test_every_floating_label_rests_full_size_on_an_empty_field_and_shrinks_on_focus
    %i[filled outlined standard].each do |floating|
      result = classes_for(:form_field_label, floating: floating)

      assert_includes result, "peer-placeholder-shown:scale-100", floating
      assert_includes result, "peer-has-[input:not(:focus):placeholder-shown]:scale-100", floating
      assert_includes result, "peer-focus-within:scale-75", floating
    end
  end

  def test_form_field_floating_label_turns_primary_on_focus
    assert_includes classes_for(:form_field_label, floating: :filled), "peer-focus-within:text-(--sp-color-primary)"
  end

  def test_form_field_floating_label_is_the_error_color_with_an_error
    assert_includes classes_for(:form_field_label, floating: :filled, error: true), "text-(--sp-color-error)"
  end

  def test_form_field_floating_label_stays_the_error_color_on_focus
    refute_includes classes_for(:form_field_label, floating: :filled, error: true),
                    "peer-focus-within:text-(--sp-color-primary)"
  end

  # :form_field_choice_items

  def test_form_field_choice_items_stack_in_a_column
    assert_includes classes_for(:form_field_choice_items), "flex-col"
  end

  def test_form_field_choice_items_inline_wrap_in_a_row
    result = classes_for(:form_field_choice_items, layout: :inline)

    assert_includes result, "flex-row"
    assert_includes result, "flex-wrap"
  end
end
