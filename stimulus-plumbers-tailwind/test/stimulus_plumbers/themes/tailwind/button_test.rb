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

  # :button variants

  def test_button_includes_primary_variant_classes_by_default
    result = classes_for(:button)

    assert_includes result, "bg-(--sp-color-primary)"
    assert_includes result, "text-(--sp-color-primary-fg)"
  end

  def test_button_falls_back_to_primary_for_unknown_variant
    assert_includes classes_for(:button, variant: :unknown), "bg-(--sp-color-primary)"
  end

  def test_button_secondary_variant_includes_muted_background
    result = classes_for(:button, variant: :secondary)

    assert_includes result, "bg-(--sp-color-muted)"
    refute_includes result, "bg-(--sp-color-primary)"
  end

  def test_button_outline_variant_includes_transparent_background_and_border
    result = classes_for(:button, variant: :outline)

    assert_includes result, "bg-transparent"
    assert_includes result, "border-(--sp-color-border)"
    refute_includes result, "bg-(--sp-color-primary)"
  end

  def test_button_destructive_variant_includes_destructive_colors
    result = classes_for(:button, variant: :destructive)

    assert_includes result, "bg-(--sp-color-destructive)"
    assert_includes result, "text-(--sp-color-destructive-fg)"
    refute_includes result, "bg-(--sp-color-primary)"
  end

  def test_button_ghost_variant_includes_muted_hover_only
    result = classes_for(:button, variant: :ghost)

    assert_includes result, "hover:bg-(--sp-color-muted)"
    refute_includes result, "bg-(--sp-color-primary)"
  end

  def test_button_link_variant_includes_primary_text_and_underline
    result = classes_for(:button, variant: :link)

    assert_includes result, "text-(--sp-color-primary)"
    assert_includes result, "hover:underline"
    refute_includes result, "bg-(--sp-color-primary)"
  end

  # :button sizes

  def test_button_includes_medium_size_classes_by_default
    assert_includes classes_for(:button), "h-9"
  end

  StimulusPlumbers::Themes::Schema::Ranges::SIZE.each do |size|
    define_method("test_button_resolves_#{size}_size") do
      height = { sm: "h-8", md: "h-9", lg: "h-11" }

      assert_includes classes_for(:button, size: size), height[size]
    end
  end

  # :button_group base

  def test_button_group_returns_a_classes_string
    result = classes_for(:button_group)

    assert_instance_of String, result
    assert_predicate result, :present?
  end

  def test_button_group_includes_flex_base_classes
    result = classes_for(:button_group)

    assert_includes result, "flex"
    assert_includes result, "gap-(--sp-space-2)"
  end

  # :button_group alignments (row direction)

  def test_button_group_includes_alignment_class_for_left
    assert_includes classes_for(:button_group, alignment: :left), "justify-start"
  end

  def test_button_group_includes_alignment_class_for_right
    assert_includes classes_for(:button_group, alignment: :right), "justify-end"
  end

  def test_button_group_includes_alignment_classes_for_center
    result = classes_for(:button_group, alignment: :center)

    assert_includes result, "justify-center"
    assert_includes result, "items-center"
  end

  def test_button_group_includes_alignment_class_for_top
    assert_includes classes_for(:button_group, alignment: :top), "items-start"
  end

  def test_button_group_includes_alignment_class_for_bottom
    assert_includes classes_for(:button_group, alignment: :bottom), "items-end"
  end

  # :button_group alignments (col direction)

  def test_button_group_col_includes_alignment_class_for_top
    assert_includes classes_for(:button_group, direction: :col, alignment: :top), "justify-start"
  end

  def test_button_group_col_includes_alignment_classes_for_center
    result = classes_for(:button_group, direction: :col, alignment: :center)

    assert_includes result, "justify-center"
    assert_includes result, "items-center"
  end

  def test_button_group_col_includes_alignment_class_for_bottom
    assert_includes classes_for(:button_group, direction: :col, alignment: :bottom), "justify-end"
  end

  def test_button_group_col_includes_alignment_class_for_left
    assert_includes classes_for(:button_group, direction: :col, alignment: :left), "items-start"
  end

  def test_button_group_col_includes_alignment_class_for_right
    assert_includes classes_for(:button_group, direction: :col, alignment: :right), "items-end"
  end
end
