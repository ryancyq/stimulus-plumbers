# frozen_string_literal: true

require "test_helper"

class TailwindThemeButtonTest < Minitest::Test
  def setup
    @theme = StimulusPlumbers::Themes::TailwindTheme.new
  end

  def classes_for(component, **args)
    @theme.resolve(component, **args)[:classes]
  end

  # :button base

  def test_button_returns_a_classes_string
    result = classes_for(:button)

    assert_instance_of String, result
    assert_predicate result, :present?
  end

  def test_button_includes_base_layout_classes
    result = classes_for(:button)

    assert_includes result, "inline-flex"
    assert_includes result, "items-center"
    assert_includes result, "font-medium"
  end

  # :button default (type: primary, variant: default)

  def test_button_default_sets_primary_css_variables
    result = classes_for(:button)

    assert_includes result, "[--btn-bg:var(--sp-color-primary)]"
    assert_includes result, "[--btn-fg:var(--sp-color-primary-fg)]"
    assert_includes result, "[--btn-ring:var(--sp-color-primary)]"
  end

  def test_button_default_references_btn_variables_for_bg_and_text
    result = classes_for(:button)

    assert_includes result, "bg-(--btn-bg)"
    assert_includes result, "text-(--btn-fg)"
  end

  def test_button_falls_back_to_default_variant_for_unknown_variant
    result = classes_for(:button, variant: :unknown)

    assert_includes result, "[--btn-bg:var(--sp-color-primary)]"
  end

  def test_button_falls_back_to_primary_type_for_unknown_type
    result = classes_for(:button, type: :unknown)

    assert_includes result, "bg-(--btn-bg)"
  end

  # :button types

  def test_button_secondary_type_uses_tinted_background
    result = classes_for(:button, type: :secondary)

    assert_includes result, "bg-(--btn-bg)/15"
    assert_includes result, "text-(--btn-bg)"
    refute_includes result, "bg-(--btn-bg) "
  end

  def test_button_tertiary_type_uses_surface_bg_with_light_border
    result = classes_for(:button, type: :tertiary)

    assert_includes result, "bg-(--sp-color-bg)"
    assert_includes result, "border-(--btn-bg)/40"
    assert_includes result, "text-(--btn-bg)"
  end

  def test_button_outline_type_fills_on_hover
    result = classes_for(:button, type: :outline)

    assert_includes result, "bg-(--sp-color-bg)"
    assert_includes result, "border-(--btn-bg)"
    assert_includes result, "hover:bg-(--btn-bg)"
    assert_includes result, "hover:text-(--btn-fg)"
  end

  def test_button_ghost_type_uses_transparent_bg_with_muted_hover
    result = classes_for(:button, type: :ghost)

    assert_includes result, "bg-transparent"
    assert_includes result, "hover:bg-(--btn-bg)/10"
  end

  # :button variants

  def test_button_destructive_variant_sets_destructive_css_variables
    result = classes_for(:button, variant: :destructive)

    assert_includes result, "[--btn-bg:var(--sp-color-destructive)]"
    assert_includes result, "[--btn-fg:var(--sp-color-destructive-fg)]"
  end

  def test_button_success_variant_sets_success_css_variables
    result = classes_for(:button, variant: :success)

    assert_includes result, "[--btn-bg:var(--sp-color-success)]"
    assert_includes result, "[--btn-fg:var(--sp-color-success-fg)]"
    assert_includes result, "[--btn-ring:var(--sp-color-success-ring)]"
  end

  def test_button_warning_variant_sets_warning_css_variables
    result = classes_for(:button, variant: :warning)

    assert_includes result, "[--btn-bg:var(--sp-color-warning)]"
    assert_includes result, "[--btn-fg:var(--sp-color-warning-fg)]"
    assert_includes result, "[--btn-ring:var(--sp-color-warning-ring)]"
  end

  def test_button_info_variant_sets_info_css_variables
    result = classes_for(:button, variant: :info)

    assert_includes result, "[--btn-bg:var(--sp-color-info)]"
    assert_includes result, "[--btn-fg:var(--sp-color-info-fg)]"
    assert_includes result, "[--btn-ring:var(--sp-color-info-ring)]"
  end

  def test_button_type_and_variant_combine_independently
    result = classes_for(:button, type: :outline, variant: :destructive)

    assert_includes result, "[--btn-bg:var(--sp-color-destructive)]"
    assert_includes result, "bg-(--sp-color-bg)"
    assert_includes result, "hover:bg-(--btn-bg)"
  end

  # :button sizes

  def test_button_includes_medium_size_classes_by_default
    assert_includes classes_for(:button), "h-9"
  end

  def test_button_resolves_nil_size_applies_no_size_classes
    result = classes_for(:button, size: nil)

    refute_includes result, "h-7"
    refute_includes result, "h-8"
    refute_includes result, "h-9"
    refute_includes result, "h-11"
    refute_includes result, "h-14"
  end

  StimulusPlumbers::Themes::Schema::Ranges::SIZE.each do |size|
    define_method("test_button_resolves_#{size}_size") do
      height = { xs: "h-7", sm: "h-8", md: "h-9", lg: "h-11", xl: "h-14" }

      assert_includes classes_for(:button, size: size), height[size]
    end
  end

  # :button_group base

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

  # :button_group layout: :inline

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

  def test_button_group_inline_uses_sp_button_group_class
    assert_includes classes_for(:button_group, layout: :inline), "sp-button-group"
  end

  # :button_group layout: :stacked

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

  def test_button_group_stacked_uses_sp_button_group_stacked_class
    assert_includes classes_for(:button_group, layout: :stacked), "sp-button-group-stacked"
  end

  def test_button_group_stacked_does_not_include_inline_group_class
    refute_includes classes_for(:button_group, layout: :stacked), "sp-button-group "
  end

  # :button fab type

  def test_button_fab_type_includes_rounded_full
    assert_includes classes_for(:button, type: :fab), "rounded-full"
  end

  def test_button_fab_type_includes_shadow
    assert_includes classes_for(:button, type: :fab), "shadow-lg"
  end

  def test_button_fab_type_references_btn_variables
    result = classes_for(:button, type: :fab)

    assert_includes result, "bg-(--btn-bg)"
    assert_includes result, "text-(--btn-fg)"
  end

  def test_button_fab_type_includes_hover_shadow
    assert_includes classes_for(:button, type: :fab), "hover:shadow-xl"
  end

  # :button fab_outline type

  def test_button_fab_outline_type_includes_rounded_full
    assert_includes classes_for(:button, type: :fab_outline), "rounded-full"
  end

  def test_button_fab_outline_type_includes_shadow
    assert_includes classes_for(:button, type: :fab_outline), "shadow-lg"
  end

  def test_button_fab_outline_type_references_btn_border_and_text
    result = classes_for(:button, type: :fab_outline)

    assert_includes result, "border-(--btn-bg)"
    assert_includes result, "text-(--btn-bg)"
  end

  def test_button_fab_outline_type_hover_fills
    result = classes_for(:button, type: :fab_outline)

    assert_includes result, "hover:bg-(--btn-bg)"
    assert_includes result, "hover:text-(--btn-fg)"
  end

  def test_button_fab_outline_type_includes_hover_shadow
    assert_includes classes_for(:button, type: :fab_outline), "hover:shadow-xl"
  end

  # :button dashed type

  def test_button_dashed_type_includes_dashed_border
    result = classes_for(:button, type: :dashed)

    assert_includes result, "border-dashed"
    assert_includes result, "border-(--btn-bg)/60"
  end

  def test_button_dashed_type_includes_transparent_background
    assert_includes classes_for(:button, type: :dashed), "bg-transparent"
  end

  def test_button_dashed_type_includes_tinted_hover
    assert_includes classes_for(:button, type: :dashed), "hover:bg-(--btn-bg)/10"
  end

  # :button_link base

  def test_button_link_returns_a_classes_string
    result = classes_for(:button_link)

    assert_instance_of String, result
    assert_predicate result, :present?
  end

  def test_button_link_includes_base_layout_classes
    result = classes_for(:button_link)

    assert_includes result, "inline-flex"
    assert_includes result, "items-center"
    assert_includes result, "justify-center"
    assert_includes result, "font-medium"
  end

  def test_button_link_uses_neutral_surface
    result = classes_for(:button_link)

    assert_includes result, "bg-(--sp-color-bg-muted)"
    assert_includes result, "text-(--sp-color-fg)"
    assert_includes result, "border-(--sp-color-border)"
  end

  def test_button_link_does_not_use_btn_bg_for_background
    result = classes_for(:button_link)

    refute_includes result, "bg-(--btn-bg)"
    refute_includes result, "text-(--btn-fg)"
  end

  def test_button_link_includes_focus_ring_from_variant
    assert_includes classes_for(:button_link), "focus-visible:ring-(--btn-ring)"
  end

  def test_button_link_does_not_include_button_group_selectors
    result = classes_for(:button_link)

    refute_includes result, "sp-button-group"
  end

  # :button_link variants (focus ring only)

  def test_button_link_default_variant_sets_primary_ring
    assert_includes classes_for(:button_link), "[--btn-ring:var(--sp-color-primary)]"
  end

  def test_button_link_destructive_variant_sets_destructive_ring
    assert_includes classes_for(:button_link, variant: :destructive), "[--btn-ring:var(--sp-color-destructive)]"
  end

  def test_button_link_falls_back_to_default_variant_for_unknown
    assert_includes classes_for(:button_link, variant: :unknown), "[--btn-ring:var(--sp-color-primary)]"
  end

  # :button_link sizes

  def test_button_link_includes_medium_size_by_default
    assert_includes classes_for(:button_link), "h-9"
  end

  StimulusPlumbers::Themes::Schema::Ranges::SIZE.each do |size|
    define_method("test_button_link_resolves_#{size}_size") do
      height = { xs: "h-7", sm: "h-8", md: "h-9", lg: "h-11", xl: "h-14" }

      assert_includes classes_for(:button_link, size: size), height[size]
    end
  end
end
