# frozen_string_literal: true

require "test_helper"

class TailwindThemeCardTest < Minitest::Test
  include ThemeAssertions

  def setup
    @theme = StimulusPlumbers::Themes::TailwindTheme.new
  end

  # ── card (root) ─────────────────────────────────────────────────────────────

  def test_card_is_a_rounded_bordered_surface
    result = classes_for(:card)

    assert_includes result, "border"
    assert_includes result, "bg-(--sp-color-bg)"
    assert_includes result, "rounded-(--sp-radius-md)"
  end

  def test_card_border_follows_the_variant_ring
    assert_includes classes_for(:card), "border-(--card-ring)"
  end

  def test_card_default_variant_is_tertiary
    result = classes_for(:card)

    assert_includes result, "[--card-ring:var(--sp-color-muted-fg)]"
  end

  def test_card_primary_variant_takes_the_primary_ring
    result = classes_for(:card, variant: :primary)

    assert_includes result, "[--card-ring:var(--sp-color-primary)]"
    refute_includes result, "[--card-ring:var(--sp-color-muted-fg)]"
  end

  def test_card_secondary_variant_takes_the_secondary_ring
    assert_includes classes_for(:card, variant: :secondary), "[--card-ring:var(--sp-color-secondary)]"
  end

  def test_card_success_variant_takes_the_success_ring
    assert_includes classes_for(:card, variant: :success), "[--card-ring:var(--sp-color-success)]"
  end

  def test_card_destructive_variant_takes_the_destructive_ring
    assert_includes classes_for(:card, variant: :destructive), "[--card-ring:var(--sp-color-destructive)]"
  end

  def test_card_warning_variant_takes_the_warning_ring
    assert_includes classes_for(:card, variant: :warning), "[--card-ring:var(--sp-color-warning)]"
  end

  def test_card_info_variant_takes_the_info_ring
    assert_includes classes_for(:card, variant: :info), "[--card-ring:var(--sp-color-info)]"
  end

  def test_card_unknown_variant_falls_back_to_tertiary
    assert_includes classes_for(:card, variant: :unknown), "[--card-ring:var(--sp-color-muted-fg)]"
  end

  # ── card_title ──────────────────────────────────────────────────────────────

  def test_card_title_is_semibold_foreground_text
    result = classes_for(:card_title)

    assert_includes result, "font-semibold"
    assert_includes result, "text-(--sp-color-fg)"
  end

  # ── card_icon ───────────────────────────────────────────────────────────────

  def test_card_icon_strokes_in_the_text_color
    assert_includes classes_for(:card_icon), "stroke-current"
  end
end
