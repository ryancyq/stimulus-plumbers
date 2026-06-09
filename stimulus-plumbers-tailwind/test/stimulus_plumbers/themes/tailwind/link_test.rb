# frozen_string_literal: true

require "test_helper"

class TailwindThemeLinkTest < Minitest::Test
  def setup
    @theme = StimulusPlumbers::Themes::TailwindTheme.new
  end

  def classes_for(component, **args)
    @theme.resolve(component, **args)[:classes]
  end

  # :link type: :default base

  def test_link_returns_a_classes_string
    result = classes_for(:link)

    assert_instance_of String, result
    assert_predicate result, :present?
  end

  def test_link_includes_inline_flex_for_icon_alignment
    result = classes_for(:link)

    assert_includes result, "inline-flex"
    assert_includes result, "items-center"
  end

  def test_link_includes_hover_underline
    assert_includes classes_for(:link), "hover:underline"
  end

  def test_link_does_not_include_always_underline
    refute_includes classes_for(:link), " underline "
  end

  def test_link_includes_focus_ring
    result = classes_for(:link)

    assert_includes result, "focus-visible:ring-2"
    assert_includes result, "focus-visible:ring-(--link-ring)"
  end

  def test_link_does_not_include_button_base_classes
    result = classes_for(:link)

    refute_includes result, "rounded"
    refute_includes result, "sp-button-group"
    refute_includes result, "h-9"
    refute_includes result, "px-"
  end

  # :link type: :default variants

  def test_link_default_sets_primary_css_variables
    result = classes_for(:link)

    assert_includes result, "[--link-color:var(--sp-color-primary)]"
    assert_includes result, "[--link-ring:var(--sp-color-primary)]"
  end

  def test_link_references_link_color_variable
    assert_includes classes_for(:link), "text-(--link-color)"
  end

  def test_link_falls_back_to_default_variant_for_unknown_variant
    assert_includes classes_for(:link, variant: :unknown), "[--link-color:var(--sp-color-primary)]"
  end

  def test_link_destructive_variant_sets_destructive_css_variables
    result = classes_for(:link, variant: :destructive)

    assert_includes result, "[--link-color:var(--sp-color-destructive)]"
    assert_includes result, "[--link-ring:var(--sp-color-destructive)]"
  end

  def test_link_success_variant_sets_success_css_variables
    result = classes_for(:link, variant: :success)

    assert_includes result, "[--link-color:var(--sp-color-success)]"
    assert_includes result, "[--link-ring:var(--sp-color-success-ring)]"
  end

  def test_link_warning_variant_sets_warning_css_variables
    result = classes_for(:link, variant: :warning)

    assert_includes result, "[--link-color:var(--sp-color-warning)]"
    assert_includes result, "[--link-ring:var(--sp-color-warning-ring)]"
  end

  def test_link_info_variant_sets_info_css_variables
    result = classes_for(:link, variant: :info)

    assert_includes result, "[--link-color:var(--sp-color-info)]"
    assert_includes result, "[--link-ring:var(--sp-color-info-ring)]"
  end

  def test_link_does_not_set_btn_css_variables
    result = classes_for(:link)

    refute_includes result, "--btn-bg"
    refute_includes result, "--btn-fg"
    refute_includes result, "--btn-ring"
  end

  # :link type: :button base

  def test_link_button_type_returns_a_classes_string
    result = classes_for(:link, type: :button)

    assert_instance_of String, result
    assert_predicate result, :present?
  end

  def test_link_button_type_includes_button_layout_classes
    result = classes_for(:link, type: :button)

    assert_includes result, "inline-flex"
    assert_includes result, "items-center"
    assert_includes result, "justify-center"
    assert_includes result, "font-medium"
  end

  def test_link_button_type_uses_muted_background
    assert_includes classes_for(:link, type: :button), "bg-(--sp-color-bg-muted)"
  end

  def test_link_button_type_uses_link_bg_for_text_and_border
    result = classes_for(:link, type: :button)

    assert_includes result, "text-(--link-bg)"
    assert_includes result, "border-(--link-bg)/40"
  end

  def test_link_button_type_includes_fixed_medium_size
    result = classes_for(:link, type: :button)

    assert_includes result, "h-9"
    assert_includes result, "px-(--sp-space-4)"
  end

  def test_link_button_type_includes_focus_ring
    result = classes_for(:link, type: :button)

    assert_includes result, "focus-visible:ring-2"
    assert_includes result, "focus-visible:ring-(--link-ring)"
  end

  def test_link_button_type_does_not_include_hover_underline
    refute_includes classes_for(:link, type: :button), "hover:underline"
  end

  def test_link_button_type_does_not_use_link_color_for_text
    refute_includes classes_for(:link, type: :button), "text-(--link-color)"
  end

  # :link type: :button variants

  def test_link_button_type_default_variant_sets_primary_variables
    result = classes_for(:link, type: :button)

    assert_includes result, "[--link-bg:var(--sp-color-primary)]"
    assert_includes result, "[--link-ring:var(--sp-color-primary)]"
  end

  def test_link_button_type_destructive_variant_sets_destructive_variables
    result = classes_for(:link, type: :button, variant: :destructive)

    assert_includes result, "[--link-bg:var(--sp-color-destructive)]"
    assert_includes result, "[--link-ring:var(--sp-color-destructive)]"
  end

  def test_link_button_type_success_variant_sets_success_variables
    result = classes_for(:link, type: :button, variant: :success)

    assert_includes result, "[--link-bg:var(--sp-color-success)]"
    assert_includes result, "[--link-ring:var(--sp-color-success-ring)]"
  end

  def test_link_button_type_warning_variant_sets_warning_variables
    result = classes_for(:link, type: :button, variant: :warning)

    assert_includes result, "[--link-bg:var(--sp-color-warning)]"
    assert_includes result, "[--link-ring:var(--sp-color-warning-ring)]"
  end

  def test_link_button_type_info_variant_sets_info_variables
    result = classes_for(:link, type: :button, variant: :info)

    assert_includes result, "[--link-bg:var(--sp-color-info)]"
    assert_includes result, "[--link-ring:var(--sp-color-info-ring)]"
  end

  def test_link_button_type_falls_back_to_default_variant_for_unknown
    result = classes_for(:link, type: :button, variant: :unknown)

    assert_includes result, "[--link-bg:var(--sp-color-primary)]"
  end

  # :link type: :card base

  def test_link_card_type_returns_a_classes_string
    result = classes_for(:link, type: :card)

    assert_instance_of String, result
    assert_predicate result, :present?
  end

  def test_link_card_type_uses_neutral_background_and_text
    result = classes_for(:link, type: :card)

    assert_includes result, "bg-(--sp-color-bg)"
    assert_includes result, "text-(--sp-color-muted-fg)"
  end

  def test_link_card_type_uses_full_padding_not_height
    result = classes_for(:link, type: :card)

    assert_includes result, "p-(--sp-space-4)"
    refute_includes result, "h-9"
  end

  def test_link_card_type_uses_justify_start_layout
    result = classes_for(:link, type: :card)

    assert_includes result, "justify-start"
    assert_includes result, "flex-1"
    assert_includes result, "gap-(--sp-space-3)"
    assert_includes result, "[&>:last-child:not(:first-child)]:ml-auto"
    refute_includes result, "justify-between"
  end

  def test_link_card_type_includes_border_shadow_and_hover_upgrades
    result = classes_for(:link, type: :card)

    assert_includes result, "border-(--sp-color-border)"
    assert_includes result, "shadow-(--sp-shadow-xs)"
    assert_includes result, "hover:border-(--sp-color-border-strong)"
    assert_includes result, "hover:text-(--sp-color-fg)"
  end

  def test_link_card_type_sets_default_card_ring
    result = classes_for(:link, type: :card)

    assert_includes result, "[--card-ring:var(--sp-color-primary)]"
    assert_includes result, "focus-visible:ring-(--card-ring)"
  end

  def test_link_card_type_does_not_include_hover_underline
    refute_includes classes_for(:link, type: :card), "hover:underline"
  end

  def test_link_card_type_does_not_use_link_color_or_bg
    result = classes_for(:link, type: :card)

    refute_includes result, "--link-color"
    refute_includes result, "--link-bg"
  end

  def test_link_card_type_does_not_include_fixed_height
    refute_includes classes_for(:link, type: :card), "h-9"
  end

  # :link type: :card variants

  def test_link_card_type_success_variant_sets_card_ring
    result = classes_for(:link, type: :card, variant: :success)

    assert_includes result, "[--card-ring:var(--sp-color-success)]"
    refute_includes result, "[--card-ring:var(--sp-color-primary)]"
  end

  def test_link_card_type_destructive_variant_sets_card_ring
    result = classes_for(:link, type: :card, variant: :destructive)

    assert_includes result, "[--card-ring:var(--sp-color-destructive)]"
  end

  def test_link_card_type_falls_back_to_default_card_ring_for_unknown_variant
    result = classes_for(:link, type: :card, variant: :unknown)

    assert_includes result, "[--card-ring:var(--sp-color-primary)]"
  end

  # :link_icon

  def test_link_icon_returns_a_classes_string
    result = classes_for(:link_icon)

    assert_instance_of String, result
    assert_predicate result, :present?
  end

  def test_link_icon_includes_size_class
    assert_includes classes_for(:link_icon), "size-(--sp-control-size)"
  end

  def test_link_icon_includes_stroke_current
    assert_includes classes_for(:link_icon), "stroke-current"
  end
end
