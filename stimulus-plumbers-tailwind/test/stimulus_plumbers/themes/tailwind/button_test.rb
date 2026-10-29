# frozen_string_literal: true

require "test_helper"

class TailwindThemeButtonTest < Minitest::Test
  include ThemeAssertions

  def setup
    @theme = StimulusPlumbers::Themes::TailwindTheme.new
  end

  # ── base ────────────────────────────────────────────────────────────────────

  def test_button_text_is_medium_weight
    assert_includes classes_for(:button), "font-medium"
  end

  def test_button_shows_the_themed_focus_ring
    result = classes_for(:button)

    assert_includes result, "focus-visible:ring-(length:--sp-focus-ring-width)"
    assert_includes result, "focus-visible:ring-offset-(length:--sp-focus-ring-offset)"
  end

  def test_button_falls_back_to_default_type_for_unknown_type
    result = classes_for(:button, type: :unknown)

    assert_includes result, "bg-(--btn-bg)"
  end

  def test_button_falls_back_to_primary_variant_for_unknown_variant
    result = classes_for(:button, variant: :unknown)

    assert_includes result, "[--btn-bg:var(--sp-color-primary)]"
  end

  # ── variants: CSS variables emitted ─────────────────────────────────────────

  def test_button_primary_variant_takes_the_primary_palette
    result = classes_for(:button, variant: :primary)

    assert_includes result, "[--btn-bg:var(--sp-color-primary)]"
    assert_includes result, "[--btn-fg:var(--sp-color-primary-fg)]"
    assert_includes result, "[--btn-accent:var(--sp-color-primary)]"
    assert_includes result, "[--btn-border:var(--sp-color-primary-border)]"
    assert_includes result, "[--btn-ring:var(--sp-color-primary-ring)]"
  end

  def test_button_secondary_variant_takes_the_secondary_palette
    result = classes_for(:button, variant: :secondary)

    assert_includes result, "[--btn-bg:var(--sp-color-secondary)]"
    assert_includes result, "[--btn-fg:var(--sp-color-secondary-fg)]"
    assert_includes result, "[--btn-accent:var(--sp-color-secondary)]"
    assert_includes result, "[--btn-border:var(--sp-color-secondary-border)]"
    assert_includes result, "[--btn-ring:var(--sp-color-secondary-ring)]"
  end

  def test_button_tertiary_variant_takes_the_muted_palette_with_a_foreground_accent
    result = classes_for(:button, variant: :tertiary)

    assert_includes result, "[--btn-bg:var(--sp-color-muted)]"
    assert_includes result, "[--btn-fg:var(--sp-color-muted-fg)]"
    assert_includes result, "[--btn-accent:var(--sp-color-fg)]"
    assert_includes result, "[--btn-border:var(--sp-color-muted-border)]"
    assert_includes result, "[--btn-ring:var(--sp-color-muted-ring)]"
  end

  def test_button_success_variant_takes_the_success_palette
    result = classes_for(:button, variant: :success)

    assert_includes result, "[--btn-bg:var(--sp-color-success)]"
    assert_includes result, "[--btn-fg:var(--sp-color-success-fg)]"
    assert_includes result, "[--btn-accent:var(--sp-color-success)]"
    assert_includes result, "[--btn-border:var(--sp-color-success-border)]"
    assert_includes result, "[--btn-ring:var(--sp-color-success-ring)]"
  end

  def test_button_destructive_variant_takes_the_destructive_palette
    result = classes_for(:button, variant: :destructive)

    assert_includes result, "[--btn-bg:var(--sp-color-destructive)]"
    assert_includes result, "[--btn-fg:var(--sp-color-destructive-fg)]"
    assert_includes result, "[--btn-accent:var(--sp-color-destructive)]"
    assert_includes result, "[--btn-border:var(--sp-color-destructive-border)]"
    assert_includes result, "[--btn-ring:var(--sp-color-destructive-ring)]"
  end

  def test_button_warning_variant_takes_the_warning_palette
    result = classes_for(:button, variant: :warning)

    assert_includes result, "[--btn-bg:var(--sp-color-warning)]"
    assert_includes result, "[--btn-fg:var(--sp-color-warning-fg)]"
    assert_includes result, "[--btn-accent:var(--sp-color-warning)]"
    assert_includes result, "[--btn-border:var(--sp-color-warning-border)]"
    assert_includes result, "[--btn-ring:var(--sp-color-warning-ring)]"
  end

  def test_button_info_variant_takes_the_info_palette
    result = classes_for(:button, variant: :info)

    assert_includes result, "[--btn-bg:var(--sp-color-info)]"
    assert_includes result, "[--btn-fg:var(--sp-color-info-fg)]"
    assert_includes result, "[--btn-accent:var(--sp-color-info)]"
    assert_includes result, "[--btn-border:var(--sp-color-info-border)]"
    assert_includes result, "[--btn-ring:var(--sp-color-info-ring)]"
  end

  # ── type: :default ───────────────────────────────────────────────────────────

  def test_button_default_type_is_filled
    result = classes_for(:button, type: :default)

    assert_includes result, "bg-(--btn-bg)"
    assert_includes result, "text-(--btn-fg)"
    refute_includes result, "text-(--btn-accent)"
  end

  def test_button_default_type_border_follows_the_variant
    assert_includes classes_for(:button, type: :default), "border-(--btn-border)"
  end

  def test_button_default_type_hover_darkens_the_background
    assert_includes classes_for(:button, type: :default), "hover:bg-(--btn-bg)/90"
  end

  # ── type: :outline ───────────────────────────────────────────────────────────

  def test_button_outline_type_is_a_surface_with_accent_text
    result = classes_for(:button, type: :outline)

    assert_includes result, "bg-(--sp-color-bg)"
    assert_includes result, "text-(--btn-accent)"
    refute_includes result, "text-(--btn-fg)"
  end

  def test_button_outline_type_border_follows_the_variant
    assert_includes classes_for(:button, type: :outline), "border-(--btn-border)"
  end

  def test_button_outline_type_hover_tints_the_background
    assert_includes classes_for(:button, type: :outline), "hover:bg-(--btn-accent)/10"
  end

  def test_button_outline_type_does_not_change_text_on_hover
    refute_class_containing classes_for(:button, type: :outline), "hover:text-"
  end

  def test_button_type_and_variant_combine_independently
    result = classes_for(:button, type: :outline, variant: :destructive)

    assert_includes result, "[--btn-bg:var(--sp-color-destructive)]"
    assert_includes result, "bg-(--sp-color-bg)"
    assert_includes result, "text-(--btn-accent)"
    assert_includes result, "hover:bg-(--btn-accent)/10"
  end

  # ── type: :ghost ─────────────────────────────────────────────────────────────

  def test_button_ghost_type_is_transparent_with_accent_text
    result = classes_for(:button, type: :ghost)

    assert_includes result, "bg-transparent"
    assert_includes result, "text-(--btn-accent)"
    refute_includes result, "text-(--btn-fg)"
  end

  def test_button_ghost_type_has_transparent_border
    assert_includes classes_for(:button, type: :ghost), "border-transparent"
  end

  def test_button_ghost_type_hover_tints_the_background
    assert_includes classes_for(:button, type: :ghost), "hover:bg-(--btn-accent)/10"
  end

  # ── type: :fab ───────────────────────────────────────────────────────────────

  def test_button_fab_type_is_filled
    result = classes_for(:button, type: :fab)

    assert_includes result, "bg-(--btn-bg)"
    assert_includes result, "text-(--btn-fg)"
    refute_includes result, "text-(--btn-accent)"
  end

  def test_button_fab_type_is_fully_rounded
    assert_includes classes_for(:button, type: :fab), "rounded-(--sp-radius-full)"
  end

  def test_button_fab_type_is_raised_and_lifts_on_hover
    result = classes_for(:button, type: :fab)

    assert_includes result, "shadow-(--sp-shadow-lg)"
    assert_includes result, "hover:shadow-(--sp-shadow-xl)"
  end

  def test_button_fab_type_hover_darkens_the_background
    assert_includes classes_for(:button, type: :fab), "hover:bg-(--btn-bg)/90"
  end

  # ── type: :fab_outline ───────────────────────────────────────────────────────

  def test_button_fab_outline_type_is_transparent_with_accent_text_at_rest
    result = classes_for(:button, type: :fab_outline)

    assert_includes result, "bg-transparent"
    assert_includes result, "text-(--btn-accent)"
    refute_includes result, "bg-(--btn-bg)"
  end

  def test_button_fab_outline_type_is_fully_rounded
    assert_includes classes_for(:button, type: :fab_outline), "rounded-(--sp-radius-full)"
  end

  def test_button_fab_outline_type_is_raised_and_lifts_on_hover
    result = classes_for(:button, type: :fab_outline)

    assert_includes result, "shadow-(--sp-shadow-lg)"
    assert_includes result, "hover:shadow-(--sp-shadow-xl)"
  end

  def test_button_fab_outline_type_fills_on_hover
    result = classes_for(:button, type: :fab_outline)

    assert_includes result, "hover:bg-(--btn-bg)"
    assert_includes result, "hover:text-(--btn-fg)"
  end

  def test_button_fab_outline_type_border_follows_the_variant
    assert_includes classes_for(:button, type: :fab_outline), "border-(--btn-border)"
  end

  # ── type: :dashed ────────────────────────────────────────────────────────────

  def test_button_dashed_type_is_a_surface_with_accent_text
    result = classes_for(:button, type: :dashed)

    assert_includes result, "bg-(--sp-color-bg)"
    assert_includes result, "text-(--btn-accent)"
    refute_includes result, "bg-transparent"
    refute_includes result, "text-(--btn-fg)"
  end

  def test_button_dashed_type_has_a_dashed_variant_border
    result = classes_for(:button, type: :dashed)

    assert_includes result, "border-dashed"
    assert_includes result, "border-(--btn-border)"
  end

  def test_button_dashed_type_hover_tints_the_background
    assert_includes classes_for(:button, type: :dashed), "hover:bg-(--btn-accent)/10"
  end

  # ── type: :card ──────────────────────────────────────────────────────────────

  def test_button_card_type_is_a_surface_with_accent_text
    result = classes_for(:button, type: :card)

    assert_includes result, "bg-(--sp-color-bg)"
    assert_includes result, "text-(--btn-accent)"
    refute_includes result, "text-(--btn-fg)"
  end

  def test_button_card_type_is_raised_with_the_variant_border
    result = classes_for(:button, type: :card)

    assert_includes result, "border-(--btn-border)"
    assert_includes result, "shadow-(--sp-shadow-xs)"
  end

  def test_button_card_type_does_not_change_text_on_hover
    refute_class_containing classes_for(:button, type: :card), "hover:text-"
  end

  def test_button_card_type_hover_tints_the_background
    assert_includes classes_for(:button, type: :card), "hover:bg-(--btn-accent)/10"
  end

  def test_button_card_type_ignores_the_size
    result_md = classes_for(:button, type: :card, size: :md)
    result_xl = classes_for(:button, type: :card, size: :xl)

    assert_equal result_md, result_xl
    refute_includes result_md, "h-9"
    refute_includes result_md, "h-14"
  end

  def test_button_card_type_focus_ring_follows_the_button_variant
    result = classes_for(:button, type: :card)

    assert_includes result, "focus-visible:ring-(--btn-ring)"
    refute_class_containing result, "--card-ring"
  end

  def test_button_card_type_takes_the_variant_palette
    result = classes_for(:button, type: :card, variant: :success)

    assert_includes result, "[--btn-bg:var(--sp-color-success)]"
    assert_includes result, "[--btn-accent:var(--sp-color-success)]"
    refute_includes result, "[--btn-bg:var(--sp-color-primary)]"
  end

  # ── sizes ────────────────────────────────────────────────────────────────────

  def test_button_is_medium_height_by_default
    assert_includes classes_for(:button), "h-9"
  end

  def test_button_without_a_size_has_no_fixed_height
    result = classes_for(:button, size: nil)

    refute_includes result, "h-7"
    refute_includes result, "h-8"
    refute_includes result, "h-9"
    refute_includes result, "h-11"
    refute_includes result, "h-14"
  end

  StimulusPlumbers::Themes::Schema::Button::Ranges::SIZE.each do |size|
    define_method("test_button_resolves_#{size}_size") do
      height = { xs: "h-7", sm: "h-8", md: "h-9", lg: "h-11", xl: "h-14" }

      assert_includes classes_for(:button, size: size), height[size]
    end
  end

  # ── button_icon ──────────────────────────────────────────────────────────────

  def test_button_icon_strokes_in_the_text_color
    assert_includes classes_for(:button_icon), "stroke-current"
  end
end
