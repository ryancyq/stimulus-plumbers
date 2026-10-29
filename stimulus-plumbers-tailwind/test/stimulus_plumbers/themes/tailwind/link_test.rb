# frozen_string_literal: true

require "test_helper"

class TailwindThemeLinkTest < Minitest::Test
  include ThemeAssertions

  def setup
    @theme = StimulusPlumbers::Themes::TailwindTheme.new
  end

  # ── default (BASE) ──────────────────────────────────────────────────────────

  def test_link_underlines_on_hover
    assert_includes classes_for(:link), "hover:underline"
  end

  def test_link_is_not_underlined_at_rest
    refute_includes classes_for(:link), "underline"
  end

  def test_link_shows_the_link_focus_ring
    result = classes_for(:link)

    assert_includes result, "focus-visible:ring-(length:--sp-focus-ring-width)"
    assert_includes result, "focus-visible:ring-(--link-ring)"
  end

  def test_link_has_no_button_chrome
    result = classes_for(:link)

    refute_class_containing result, "rounded"
    refute_includes result, "h-9"
  end

  # ── default variants ────────────────────────────────────────────────────────

  def test_link_defaults_to_the_primary_palette
    result = classes_for(:link)

    assert_includes result, "[--link-color:var(--sp-color-primary)]"
    assert_includes result, "[--link-ring:var(--sp-color-primary)]"
  end

  def test_link_text_takes_the_link_color
    assert_includes classes_for(:link), "text-(--link-color)"
  end

  def test_link_falls_back_to_default_variant_for_unknown_variant
    assert_includes classes_for(:link, variant: :unknown), "[--link-color:var(--sp-color-primary)]"
  end

  def test_link_destructive_variant_takes_the_destructive_palette
    result = classes_for(:link, variant: :destructive)

    assert_includes result, "[--link-color:var(--sp-color-destructive)]"
    assert_includes result, "[--link-ring:var(--sp-color-destructive)]"
  end

  def test_link_success_variant_takes_the_success_palette
    result = classes_for(:link, variant: :success)

    assert_includes result, "[--link-color:var(--sp-color-success)]"
    assert_includes result, "[--link-ring:var(--sp-color-success-ring)]"
  end

  def test_link_warning_variant_takes_the_warning_palette
    result = classes_for(:link, variant: :warning)

    assert_includes result, "[--link-color:var(--sp-color-warning)]"
    assert_includes result, "[--link-ring:var(--sp-color-warning-ring)]"
  end

  def test_link_info_variant_takes_the_info_palette
    result = classes_for(:link, variant: :info)

    assert_includes result, "[--link-color:var(--sp-color-info)]"
    assert_includes result, "[--link-ring:var(--sp-color-info-ring)]"
  end

  def test_link_takes_no_button_palette
    result = classes_for(:link)

    refute_class_containing result, "--btn-bg"
    refute_class_containing result, "--btn-fg"
    refute_class_containing result, "--btn-ring"
  end

  # ── type: :button ───────────────────────────────────────────────────────────

  def test_link_button_type_text_is_medium_weight
    assert_includes classes_for(:link, type: :button), "font-medium"
  end

  def test_link_button_type_is_a_surface
    assert_includes classes_for(:link, type: :button), "bg-(--sp-color-bg)"
  end

  def test_link_button_type_text_and_border_take_the_link_color
    result = classes_for(:link, type: :button)

    assert_includes result, "text-(--link-color)"
    assert_includes result, "border-(--link-color)"
  end

  def test_link_button_type_hover_tints_the_background
    assert_includes classes_for(:link, type: :button), "hover:bg-(--link-bg)/10"
  end

  def test_link_button_type_does_not_change_text_on_hover
    refute_class_containing classes_for(:link, type: :button), "hover:text-"
  end

  def test_link_button_type_is_medium_height
    assert_includes classes_for(:link, type: :button), "h-9"
  end

  def test_link_button_type_shows_the_link_focus_ring
    result = classes_for(:link, type: :button)

    assert_includes result, "focus-visible:ring-(length:--sp-focus-ring-width)"
    assert_includes result, "focus-visible:ring-(--link-ring)"
  end

  def test_link_button_type_is_not_underlined_on_hover
    refute_includes classes_for(:link, type: :button), "hover:underline"
  end

  # ── type: :button variants ──────────────────────────────────────────────────

  def test_link_button_type_defaults_to_the_primary_palette
    result = classes_for(:link, type: :button)

    assert_includes result, "[--link-bg:var(--sp-color-primary)]"
    assert_includes result, "[--link-ring:var(--sp-color-primary)]"
  end

  def test_link_button_type_destructive_variant_takes_the_destructive_palette
    result = classes_for(:link, type: :button, variant: :destructive)

    assert_includes result, "[--link-bg:var(--sp-color-destructive)]"
    assert_includes result, "[--link-ring:var(--sp-color-destructive)]"
  end

  def test_link_button_type_success_variant_takes_the_success_palette
    result = classes_for(:link, type: :button, variant: :success)

    assert_includes result, "[--link-bg:var(--sp-color-success)]"
    assert_includes result, "[--link-ring:var(--sp-color-success-ring)]"
  end

  def test_link_button_type_warning_variant_takes_the_warning_palette
    result = classes_for(:link, type: :button, variant: :warning)

    assert_includes result, "[--link-bg:var(--sp-color-warning)]"
    assert_includes result, "[--link-ring:var(--sp-color-warning-ring)]"
  end

  def test_link_button_type_info_variant_takes_the_info_palette
    result = classes_for(:link, type: :button, variant: :info)

    assert_includes result, "[--link-bg:var(--sp-color-info)]"
    assert_includes result, "[--link-ring:var(--sp-color-info-ring)]"
  end

  def test_link_button_type_falls_back_to_default_variant_for_unknown
    result = classes_for(:link, type: :button, variant: :unknown)

    assert_includes result, "[--link-bg:var(--sp-color-primary)]"
  end

  # ── type: :card ─────────────────────────────────────────────────────────────

  def test_link_card_type_is_a_surface_with_link_colored_text
    result = classes_for(:link, type: :card)

    assert_includes result, "bg-(--sp-color-bg)"
    assert_includes result, "text-(--link-color)"
  end

  def test_link_card_type_has_no_button_height
    refute_includes classes_for(:link, type: :card), "h-9"
  end

  def test_link_card_type_is_raised_with_a_link_colored_border
    result = classes_for(:link, type: :card)

    assert_includes result, "border-(--link-color)"
    assert_includes result, "shadow-(--sp-shadow-xs)"
  end

  def test_link_card_type_hover_tints_the_background
    assert_includes classes_for(:link, type: :card), "hover:bg-(--link-bg)/10"
  end

  def test_link_card_type_does_not_change_text_on_hover
    refute_class_containing classes_for(:link, type: :card), "hover:text-"
  end

  def test_link_card_type_defaults_to_the_primary_palette
    result = classes_for(:link, type: :card)

    assert_includes result, "[--link-color:var(--sp-color-primary)]"
    assert_includes result, "[--link-bg:var(--sp-color-primary)]"
  end

  def test_link_card_type_focus_ring_takes_the_link_color
    result = classes_for(:link, type: :card)

    assert_includes result, "focus-visible:ring-(--link-ring)"
    refute_class_containing result, "--card-ring"
  end

  def test_link_card_type_is_not_underlined_on_hover
    refute_includes classes_for(:link, type: :card), "hover:underline"
  end

  # ── type: :card variants ────────────────────────────────────────────────────

  def test_link_card_type_success_variant_takes_the_success_palette
    result = classes_for(:link, type: :card, variant: :success)

    assert_includes result, "[--link-color:var(--sp-color-success)]"
    assert_includes result, "[--link-bg:var(--sp-color-success)]"
    assert_includes result, "[--link-ring:var(--sp-color-success-ring)]"
    refute_class_containing result, "--card-ring"
  end

  def test_link_card_type_destructive_variant_takes_the_destructive_ring
    result = classes_for(:link, type: :card, variant: :destructive)

    assert_includes result, "[--link-ring:var(--sp-color-destructive)]"
    refute_class_containing result, "--card-ring"
  end

  def test_link_card_type_falls_back_to_default_link_ring_for_unknown_variant
    result = classes_for(:link, type: :card, variant: :unknown)

    assert_includes result, "[--link-ring:var(--sp-color-primary)]"
    refute_class_containing result, "--card-ring"
  end

  # ── link_icon ────────────────────────────────────────────────────────────────

  def test_link_icon_strokes_in_the_text_color
    assert_includes classes_for(:link_icon), "stroke-current"
  end
end
