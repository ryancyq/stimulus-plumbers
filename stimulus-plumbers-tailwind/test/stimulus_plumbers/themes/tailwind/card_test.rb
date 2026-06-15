# frozen_string_literal: true

require "test_helper"

class TailwindThemeCardTest < Minitest::Test
  def setup
    @theme = StimulusPlumbers::Themes::TailwindTheme.new
  end

  def classes_for(component, **args)
    @theme.resolve(component, **args)[:classes]
  end

  # ── card (root) ─────────────────────────────────────────────────────────────

  def test_card_returns_a_classes_string
    assert_instance_of String, classes_for(:card)
    assert_predicate classes_for(:card), :present?
  end

  def test_card_includes_border_background_and_radius
    result = classes_for(:card)

    assert_includes result, "flex"
    assert_includes result, "flex-col"
    assert_includes result, "border"
    assert_includes result, "bg-(--sp-color-bg)"
    assert_includes result, "rounded-(--sp-radius-md)"
  end

  def test_card_border_uses_card_ring_variable
    assert_includes classes_for(:card), "border-(--card-ring)"
  end

  def test_card_default_variant_is_tertiary
    result = classes_for(:card)

    assert_includes result, "[--card-ring:var(--sp-color-muted-fg)]"
  end

  def test_card_primary_variant_sets_primary_ring
    result = classes_for(:card, variant: :primary)

    assert_includes result, "[--card-ring:var(--sp-color-primary)]"
    refute_includes result, "[--card-ring:var(--sp-color-muted-fg)]"
  end

  def test_card_secondary_variant_sets_secondary_ring
    assert_includes classes_for(:card, variant: :secondary), "[--card-ring:var(--sp-color-secondary)]"
  end

  def test_card_success_variant_sets_success_ring
    assert_includes classes_for(:card, variant: :success), "[--card-ring:var(--sp-color-success)]"
  end

  def test_card_destructive_variant_sets_destructive_ring
    assert_includes classes_for(:card, variant: :destructive), "[--card-ring:var(--sp-color-destructive)]"
  end

  def test_card_warning_variant_sets_warning_ring
    assert_includes classes_for(:card, variant: :warning), "[--card-ring:var(--sp-color-warning)]"
  end

  def test_card_info_variant_sets_info_ring
    assert_includes classes_for(:card, variant: :info), "[--card-ring:var(--sp-color-info)]"
  end

  def test_card_unknown_variant_falls_back_to_tertiary
    assert_includes classes_for(:card, variant: :unknown), "[--card-ring:var(--sp-color-muted-fg)]"
  end

  # ── card_header ─────────────────────────────────────────────────────────────

  def test_card_header_includes_flex_and_padding
    result = classes_for(:card_header)

    assert_includes result, "flex"
    assert_includes result, "items-center"
    assert_includes result, "px-(--sp-space-6)"
    assert_includes result, "py-(--sp-space-6)"
  end

  # ── card_title ──────────────────────────────────────────────────────────────

  def test_card_title_includes_font_semibold
    result = classes_for(:card_title)

    assert_includes result, "font-semibold"
    assert_includes result, "text-(--sp-color-fg)"
  end

  # ── card_icon ───────────────────────────────────────────────────────────────

  def test_card_icon_includes_size_and_stroke
    result = classes_for(:card_icon)

    assert_includes result, "size-(--sp-space-6)"
    assert_includes result, "stroke-current"
    assert_includes result, "shrink-0"
  end

  # ── card_body ───────────────────────────────────────────────────────────────

  def test_card_body_includes_padding
    result = classes_for(:card_body)

    assert_includes result, "px-(--sp-space-6)"
    assert_includes result, "py-(--sp-space-3)"
  end

  # ── card_action ─────────────────────────────────────────────────────────────

  def test_card_action_includes_full_width_and_alignment
    result = classes_for(:card_action)

    assert_includes result, "w-full"
    assert_includes result, "justify-start"
  end
end
