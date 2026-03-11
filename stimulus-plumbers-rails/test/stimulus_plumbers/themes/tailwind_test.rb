# frozen_string_literal: true

require "test_helper"

class TailwindThemeTest < Minitest::Test
  def setup
    @theme = StimulusPlumbers::Themes::TailwindTheme.new
  end

  def classes_for(component, **args)
    @theme.resolve(component, **args)[:classes]
  end

  # #resolve :button
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

  def test_button_includes_primary_variant_classes_by_default
    result = classes_for(:button)

    assert_includes result, "bg-[--sp-color-primary]"
    assert_includes result, "text-[--sp-color-primary-fg]"
  end

  def test_button_includes_medium_size_classes_by_default
    assert_includes classes_for(:button), "h-9"
  end

  StimulusPlumbers::Themes::Base::SCHEMA[:button][:variant][:range].each do |variant|
    define_method("test_button_resolves_#{variant}_variant_without_error") do
      classes_for(:button, variant: variant)
    end
  end

  StimulusPlumbers::Themes::Schema::Ranges::SIZE_RANGE.each do |size|
    define_method("test_button_resolves_#{size}_size") do
      height = { sm: "h-8", md: "h-9", lg: "h-11" }

      assert_includes classes_for(:button, size: size), height[size]
    end
  end

  def test_button_falls_back_to_primary_for_unknown_variant
    assert_includes classes_for(:button, variant: :unknown), "bg-[--sp-color-primary]"
  end

  # #resolve :button_group
  def test_button_group_returns_a_classes_string
    result = classes_for(:button_group)

    assert_instance_of String, result
    assert_predicate result, :present?
  end

  def test_button_group_includes_flex_base_classes
    result = classes_for(:button_group)

    assert_includes result, "flex"
    assert_includes result, "gap-[--sp-space-2]"
  end

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

  # #resolve :card
  def test_card_returns_a_classes_string
    result = classes_for(:card)

    assert_instance_of String, result
    assert_predicate result, :present?
  end

  def test_card_includes_border_and_background_classes
    result = classes_for(:card)

    assert_includes result, "border"
    assert_includes result, "bg-[--sp-color-bg]"
    assert_includes result, "rounded-[--sp-radius-lg]"
  end

  # #resolve :card_section
  def test_card_section_returns_a_classes_string_with_padding
    assert_includes classes_for(:card_section), "p-[--sp-space-6]"
  end

  # #resolve :avatar
  def test_avatar_returns_a_classes_string
    result = classes_for(:avatar)

    assert_instance_of String, result
    assert_predicate result, :present?
  end

  def test_avatar_includes_layout_and_shape_classes
    result = classes_for(:avatar)

    assert_includes result, "inline-flex"
    assert_includes result, "rounded-[--sp-radius-full]"
  end

  StimulusPlumbers::Themes::Schema::Ranges::SIZE_RANGE.each do |size|
    define_method("test_avatar_resolves_#{size}_size") do
      size_class = StimulusPlumbers::Themes::Tailwind::Avatar::SIZES[size]

      assert_includes classes_for(:avatar, size: size), size_class
    end
  end

  def test_avatar_colors_exposes_avatar_colors_as_hash_of_symbol_keys_to_css_class_strings
    colors = StimulusPlumbers::Themes::Tailwind::Avatar::COLORS

    assert_instance_of Hash, colors
    assert_predicate colors, :present?
    assert colors.keys.all?(Symbol), "expected all keys to be Symbols"
    assert colors.values.all?(String), "expected all values to be Strings"
  end

  def test_avatar_color_range_returns_the_css_class_values_of_avatar_colors
    assert_equal StimulusPlumbers::Themes::Tailwind::Avatar::COLORS.values, @theme.avatar_color_range
  end

  def test_avatar_colors_returns_avatar_colors
    assert_equal StimulusPlumbers::Themes::Tailwind::Avatar::COLORS, @theme.avatar_colors
  end

  def test_avatar_resolves_each_color_key_to_a_css_class_string
    StimulusPlumbers::Themes::Tailwind::Avatar::COLORS.each do |key, css_class|
      assert_equal css_class, @theme.avatar_colors.fetch(key)
    end
  end

  # #resolve :action_list
  def test_action_list_returns_a_classes_string_with_padding
    assert_includes classes_for(:action_list), "py-[--sp-space-1]"
  end

  # #resolve :action_list_item
  def test_action_list_item_returns_a_classes_string
    result = classes_for(:action_list_item)

    assert_instance_of String, result
    assert_predicate result, :present?
  end

  def test_action_list_item_includes_base_item_classes
    result = classes_for(:action_list_item)

    assert_includes result, "flex"
    assert_includes result, "cursor-pointer"
    assert_includes result, "rounded-[--sp-radius-sm]"
  end

  def test_action_list_item_excludes_active_classes_when_inactive
    refute_includes classes_for(:action_list_item, active: false), "bg-[--sp-color-primary]/10"
  end

  def test_action_list_item_includes_active_classes_when_active
    result = classes_for(:action_list_item, active: true)

    assert_includes result, "bg-[--sp-color-primary]/10"
    assert_includes result, "text-[--sp-color-primary]"
  end

  # #resolve :divider
  def test_divider_returns_a_classes_string_with_border
    result = classes_for(:divider)

    assert_includes result, "border-t"
    assert_includes result, "border-[--sp-color-border]"
  end

  # #resolve :popover
  def test_popover_returns_a_classes_string
    result = classes_for(:popover)

    assert_instance_of String, result
    assert_predicate result, :present?
  end

  def test_popover_includes_border_background_and_z_index_classes
    result = classes_for(:popover)

    assert_includes result, "border"
    assert_includes result, "bg-[--sp-color-bg]"
    assert_includes result, "z-[--sp-z-popover]"
  end

  # #resolve :calendar_day
  def test_calendar_day_returns_a_classes_string
    result = classes_for(:calendar_day)

    assert_instance_of String, result
    assert_predicate result, :present?
  end

  def test_calendar_day_includes_base_day_classes
    result = classes_for(:calendar_day)

    assert_includes result, "flex"
    assert_includes result, "cursor-pointer"
  end

  def test_calendar_day_includes_font_bold_when_today
    assert_includes classes_for(:calendar_day, today: true), "font-bold"
  end

  def test_calendar_day_excludes_font_bold_when_not_today
    refute_includes classes_for(:calendar_day, today: false), "font-bold"
  end

  def test_calendar_day_includes_selected_classes_when_selected
    result = classes_for(:calendar_day, selected: true)

    assert_includes result, "bg-[--sp-color-primary]"
    assert_includes result, "text-[--sp-color-primary-fg]"
  end

  def test_calendar_day_includes_outside_classes_when_outside_month
    result = classes_for(:calendar_day, outside: true)

    assert_includes result, "text-[--sp-color-muted-fg]"
    assert_includes result, "opacity-50"
  end
end
