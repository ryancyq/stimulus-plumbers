# frozen_string_literal: true

require "test_helper"

class TailwindThemeButtonTest < Minitest::Test
  def setup
    @theme = StimulusPlumbers::Themes::TailwindTheme.new
  end

  def classes_for(component, **args)
    @theme.resolve(component, **args)[:classes]
  end

  # ── base ────────────────────────────────────────────────────────────────────

  def test_button_returns_a_classes_string
    assert_instance_of String, classes_for(:button)
    assert_predicate classes_for(:button), :present?
  end

  def test_button_includes_base_structural_classes
    result = classes_for(:button)

    assert_includes result, "inline-flex"
    assert_includes result, "items-center"
    assert_includes result, "font-medium"
  end

  def test_button_includes_focus_ring_via_css_vars
    result = classes_for(:button)

    assert_includes result, "focus-visible:ring-(length:--sp-focus-ring-width)"
    assert_includes result, "focus-visible:ring-offset-(length:--sp-focus-ring-offset)"
    refute_includes result, "ring-2"
    refute_includes result, "ring-offset-2"
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

  def test_button_primary_variant_sets_five_css_variables
    result = classes_for(:button, variant: :primary)

    assert_includes result, "[--btn-bg:var(--sp-color-primary)]"
    assert_includes result, "[--btn-fg:var(--sp-color-primary-fg)]"
    assert_includes result, "[--btn-accent:var(--sp-color-primary)]"
    assert_includes result, "[--btn-border:var(--sp-color-primary-border)]"
    assert_includes result, "[--btn-ring:var(--sp-color-primary-ring)]"
  end

  def test_button_secondary_variant_sets_five_css_variables
    result = classes_for(:button, variant: :secondary)

    assert_includes result, "[--btn-bg:var(--sp-color-secondary)]"
    assert_includes result, "[--btn-fg:var(--sp-color-secondary-fg)]"
    assert_includes result, "[--btn-accent:var(--sp-color-secondary)]"
    assert_includes result, "[--btn-border:var(--sp-color-secondary-border)]"
    assert_includes result, "[--btn-ring:var(--sp-color-secondary-ring)]"
  end

  def test_button_tertiary_variant_uses_muted_bg_and_fg_text_for_accent
    result = classes_for(:button, variant: :tertiary)

    assert_includes result, "[--btn-bg:var(--sp-color-muted)]"
    assert_includes result, "[--btn-fg:var(--sp-color-muted-fg)]"
    assert_includes result, "[--btn-accent:var(--sp-color-fg)]"
    assert_includes result, "[--btn-border:var(--sp-color-muted-border)]"
    assert_includes result, "[--btn-ring:var(--sp-color-muted-ring)]"
    refute_includes result, "[--btn-accent:var(--sp-color-muted)]"
  end

  def test_button_success_variant_sets_five_css_variables
    result = classes_for(:button, variant: :success)

    assert_includes result, "[--btn-bg:var(--sp-color-success)]"
    assert_includes result, "[--btn-fg:var(--sp-color-success-fg)]"
    assert_includes result, "[--btn-accent:var(--sp-color-success)]"
    assert_includes result, "[--btn-border:var(--sp-color-success-border)]"
    assert_includes result, "[--btn-ring:var(--sp-color-success-ring)]"
  end

  def test_button_destructive_variant_sets_five_css_variables
    result = classes_for(:button, variant: :destructive)

    assert_includes result, "[--btn-bg:var(--sp-color-destructive)]"
    assert_includes result, "[--btn-fg:var(--sp-color-destructive-fg)]"
    assert_includes result, "[--btn-accent:var(--sp-color-destructive)]"
    assert_includes result, "[--btn-border:var(--sp-color-destructive-border)]"
    assert_includes result, "[--btn-ring:var(--sp-color-destructive-ring)]"
  end

  def test_button_warning_variant_sets_five_css_variables
    result = classes_for(:button, variant: :warning)

    assert_includes result, "[--btn-bg:var(--sp-color-warning)]"
    assert_includes result, "[--btn-fg:var(--sp-color-warning-fg)]"
    assert_includes result, "[--btn-accent:var(--sp-color-warning)]"
    assert_includes result, "[--btn-border:var(--sp-color-warning-border)]"
    assert_includes result, "[--btn-ring:var(--sp-color-warning-ring)]"
  end

  def test_button_info_variant_sets_five_css_variables
    result = classes_for(:button, variant: :info)

    assert_includes result, "[--btn-bg:var(--sp-color-info)]"
    assert_includes result, "[--btn-fg:var(--sp-color-info-fg)]"
    assert_includes result, "[--btn-accent:var(--sp-color-info)]"
    assert_includes result, "[--btn-border:var(--sp-color-info-border)]"
    assert_includes result, "[--btn-ring:var(--sp-color-info-ring)]"
  end

  # ── type: :default ───────────────────────────────────────────────────────────

  def test_button_default_type_uses_filled_bg_and_fg
    result = classes_for(:button, type: :default)

    assert_includes result, "bg-(--btn-bg)"
    assert_includes result, "text-(--btn-fg)"
    refute_includes result, "text-(--btn-accent)"
  end

  def test_button_default_type_uses_btn_border
    assert_includes classes_for(:button, type: :default), "border-(--btn-border)"
  end

  def test_button_default_type_hover_darkens_bg
    assert_includes classes_for(:button, type: :default), "hover:bg-(--btn-bg)/90"
  end

  # ── type: :outline ───────────────────────────────────────────────────────────

  def test_button_outline_type_uses_surface_bg_and_accent_text
    result = classes_for(:button, type: :outline)

    assert_includes result, "bg-(--sp-color-bg)"
    assert_includes result, "text-(--btn-accent)"
    refute_includes result, "text-(--btn-fg)"
  end

  def test_button_outline_type_uses_btn_border
    assert_includes classes_for(:button, type: :outline), "border-(--btn-border)"
  end

  def test_button_outline_type_hover_tints_bg
    assert_includes classes_for(:button, type: :outline), "hover:bg-(--btn-bg)/10"
  end

  def test_button_outline_type_does_not_change_text_on_hover
    refute_includes classes_for(:button, type: :outline), "hover:text-"
  end

  def test_button_type_and_variant_combine_independently
    result = classes_for(:button, type: :outline, variant: :destructive)

    assert_includes result, "[--btn-bg:var(--sp-color-destructive)]"
    assert_includes result, "bg-(--sp-color-bg)"
    assert_includes result, "text-(--btn-accent)"
    assert_includes result, "hover:bg-(--btn-bg)/10"
  end

  # ── type: :ghost ─────────────────────────────────────────────────────────────

  def test_button_ghost_type_uses_transparent_bg_and_accent_text
    result = classes_for(:button, type: :ghost)

    assert_includes result, "bg-transparent"
    assert_includes result, "text-(--btn-accent)"
    refute_includes result, "text-(--btn-fg)"
  end

  def test_button_ghost_type_has_transparent_border
    assert_includes classes_for(:button, type: :ghost), "border-transparent"
  end

  def test_button_ghost_type_hover_tints_bg
    assert_includes classes_for(:button, type: :ghost), "hover:bg-(--btn-bg)/10"
  end

  # ── type: :fab ───────────────────────────────────────────────────────────────

  def test_button_fab_type_uses_filled_bg_and_fg
    result = classes_for(:button, type: :fab)

    assert_includes result, "bg-(--btn-bg)"
    assert_includes result, "text-(--btn-fg)"
    refute_includes result, "text-(--btn-accent)"
  end

  def test_button_fab_type_uses_radius_full_token
    result = classes_for(:button, type: :fab)

    assert_includes result, "rounded-(--sp-radius-full)"
    refute_includes result, "rounded-full"
  end

  def test_button_fab_type_uses_shadow_tokens
    result = classes_for(:button, type: :fab)

    assert_includes result, "shadow-(--sp-shadow-lg)"
    assert_includes result, "hover:shadow-(--sp-shadow-xl)"
    refute_includes result.split, "shadow-lg"
    refute_includes result.split, "shadow-xl"
  end

  def test_button_fab_type_hover_darkens_bg
    assert_includes classes_for(:button, type: :fab), "hover:bg-(--btn-bg)/90"
  end

  # ── type: :fab_outline ───────────────────────────────────────────────────────

  def test_button_fab_outline_type_uses_transparent_bg_and_accent_text_at_rest
    result = classes_for(:button, type: :fab_outline)

    assert_includes result, "bg-transparent"
    assert_includes result, "text-(--btn-accent)"
    refute_includes result.split, "bg-(--btn-bg)"
  end

  def test_button_fab_outline_type_uses_radius_full_token
    result = classes_for(:button, type: :fab_outline)

    assert_includes result, "rounded-(--sp-radius-full)"
    refute_includes result, "rounded-full"
  end

  def test_button_fab_outline_type_uses_shadow_tokens
    result = classes_for(:button, type: :fab_outline)

    assert_includes result, "shadow-(--sp-shadow-lg)"
    assert_includes result, "hover:shadow-(--sp-shadow-xl)"
    refute_includes result, "shadow-lg "
  end

  def test_button_fab_outline_type_fills_on_hover
    result = classes_for(:button, type: :fab_outline)

    assert_includes result, "hover:bg-(--btn-bg)"
    assert_includes result, "hover:text-(--btn-fg)"
  end

  def test_button_fab_outline_type_uses_btn_border
    assert_includes classes_for(:button, type: :fab_outline), "border-(--btn-border)"
  end

  # ── type: :dashed ────────────────────────────────────────────────────────────

  def test_button_dashed_type_uses_surface_bg_and_accent_text
    result = classes_for(:button, type: :dashed)

    assert_includes result, "bg-(--sp-color-bg)"
    assert_includes result, "text-(--btn-accent)"
    refute_includes result, "bg-transparent"
    refute_includes result, "text-(--btn-fg)"
  end

  def test_button_dashed_type_includes_dashed_border_style
    result = classes_for(:button, type: :dashed)

    assert_includes result, "border-dashed"
    assert_includes result, "border-(--btn-border)"
  end

  def test_button_dashed_type_hover_tints_bg
    assert_includes classes_for(:button, type: :dashed), "hover:bg-(--btn-bg)/10"
  end

  # ── type: :card ──────────────────────────────────────────────────────────────

  def test_button_card_type_uses_surface_bg_and_accent_text
    result = classes_for(:button, type: :card)

    assert_includes result, "bg-(--sp-color-bg)"
    assert_includes result, "text-(--btn-accent)"
    refute_includes result, "text-(--btn-fg)"
  end

  def test_button_card_type_uses_btn_border_and_shadow
    result = classes_for(:button, type: :card)

    assert_includes result, "border-(--btn-border)"
    assert_includes result, "shadow-(--sp-shadow-xs)"
  end

  def test_button_card_type_does_not_change_text_on_hover
    refute_includes classes_for(:button, type: :card), "hover:text-"
  end

  def test_button_card_type_hover_tints_bg
    assert_includes classes_for(:button, type: :card), "hover:bg-(--btn-bg)/10"
  end

  def test_button_card_type_uses_justify_start_layout
    result = classes_for(:button, type: :card)

    assert_includes result, "justify-start"
    assert_includes result, "flex-1"
    assert_includes result, "p-(--sp-space-4)"
    assert_includes result, "[&>:last-child:not(:first-child)]:ml-auto"
  end

  def test_button_card_type_skips_size_classes
    result_md = classes_for(:button, type: :card, size: :md)
    result_xl = classes_for(:button, type: :card, size: :xl)

    assert_equal result_md, result_xl
    refute_includes result_md, "h-9"
    refute_includes result_md, "h-14"
  end

  def test_button_card_type_uses_btn_variables_not_card_ring
    result = classes_for(:button, type: :card)

    assert_includes result, "focus-visible:ring-(--btn-ring)"
    refute_includes result, "--card-ring"
  end

  def test_button_card_variant_changes_btn_variables
    result = classes_for(:button, type: :card, variant: :success)

    assert_includes result, "[--btn-bg:var(--sp-color-success)]"
    assert_includes result, "[--btn-accent:var(--sp-color-success)]"
    refute_includes result, "[--btn-bg:var(--sp-color-primary)]"
  end

  # ── sizes ────────────────────────────────────────────────────────────────────

  def test_button_includes_medium_size_by_default
    assert_includes classes_for(:button), "h-9"
  end

  def test_button_nil_size_applies_no_height
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

  def test_button_icon_returns_a_classes_string
    result = classes_for(:button_icon)

    assert_instance_of String, result
    assert_predicate result, :present?
  end

  def test_button_icon_includes_size_token
    assert_includes classes_for(:button_icon), "size-(--sp-control-size)"
  end

  def test_button_icon_includes_stroke_current
    assert_includes classes_for(:button_icon), "stroke-current"
  end

  # ── button_group ─────────────────────────────────────────────────────────────

  def test_button_group_returns_a_classes_string
    result = classes_for(:button_group)

    assert_instance_of String, result
    assert_predicate result, :present?
  end

  def test_button_group_defaults_to_inline_layout
    result = classes_for(:button_group)

    assert_includes result, "inline-flex"
    assert_includes result, "shadow-(--sp-shadow-xs)"
  end

  def test_button_group_inline_uses_horizontal_flex
    result = classes_for(:button_group, layout: :inline)

    assert_includes result, "inline-flex"
    refute_includes result, "flex-col"
  end

  def test_button_group_inline_uses_horizontal_negative_margin
    result = classes_for(:button_group, layout: :inline)

    assert_includes result, "-ml-px"
    refute_includes result, "-mt-px"
  end

  def test_button_group_inline_rounds_first_and_last_child
    result = classes_for(:button_group, layout: :inline)

    assert_includes result, "[&>*]:rounded-none"
    assert_includes result, "[&>*:first-child]:rounded-s-(--sp-radius-md)"
    assert_includes result, "[&>*:last-child]:rounded-e-(--sp-radius-md)"
  end

  def test_button_group_stacked_uses_vertical_flex
    result = classes_for(:button_group, layout: :stacked)

    assert_includes result, "flex"
    assert_includes result, "flex-col"
    refute_includes result, "inline-flex"
  end

  def test_button_group_stacked_uses_vertical_negative_margin
    result = classes_for(:button_group, layout: :stacked)

    assert_includes result, "-mt-px"
    refute_includes result, "-ml-px"
  end

  def test_button_group_stacked_rounds_first_and_last_child
    result = classes_for(:button_group, layout: :stacked)

    assert_includes result, "[&>*]:rounded-none"
    assert_includes result, "[&>*:first-child]:rounded-t-(--sp-radius-md)"
    assert_includes result, "[&>*:last-child]:rounded-b-(--sp-radius-md)"
  end

  def test_button_group_stacked_does_not_include_inline_child_rounding
    result = classes_for(:button_group, layout: :stacked)

    refute_includes result, "[&>*:first-child]:rounded-s-(--sp-radius-md)"
    refute_includes result, "[&>*:last-child]:rounded-e-(--sp-radius-md)"
  end
end
