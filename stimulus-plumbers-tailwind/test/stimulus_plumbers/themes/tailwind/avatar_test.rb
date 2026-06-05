# frozen_string_literal: true

require "test_helper"

class TailwindThemeAvatarTest < Minitest::Test
  def setup
    @theme = StimulusPlumbers::Themes::TailwindTheme.new
  end

  def classes_for(component, **args)
    @theme.resolve(component, **args)[:classes]
  end

  def test_avatar_returns_a_classes_string
    result = classes_for(:avatar)

    assert_instance_of String, result
    assert_predicate result, :present?
  end

  def test_avatar_includes_layout_and_shape_classes
    result = classes_for(:avatar)

    assert_includes result, "inline-flex"
    assert_includes result, "rounded-(--sp-radius-full)"
  end

  StimulusPlumbers::Themes::Tailwind::Avatar::SIZES.each_key do |size|
    define_method("test_avatar_resolves_#{size}_size") do
      size_class = StimulusPlumbers::Themes::Tailwind::Avatar::SIZES[size]

      assert_includes classes_for(:avatar, size: size), size_class
    end
  end

  def test_avatar_variants_exposes_variants_as_hash_of_symbol_keys_to_css_class_strings
    variants = StimulusPlumbers::Themes::Tailwind::Avatar::VARIANTS

    assert_instance_of Hash, variants
    assert_predicate variants, :present?
    assert variants.keys.all?(Symbol), "expected all keys to be Symbols"
    assert variants.values.all?(String), "expected all values to be Strings"
  end

  def test_avatar_variant_range_returns_the_css_class_values_of_avatar_variants
    assert_equal StimulusPlumbers::Themes::Tailwind::Avatar::VARIANTS.values, @theme.avatar_variant_range
  end

  def test_avatar_variants_returns_avatar_variants
    assert_equal StimulusPlumbers::Themes::Tailwind::Avatar::VARIANTS, @theme.avatar_variants
  end

  def test_avatar_resolves_each_variant_key_to_a_css_class_string
    StimulusPlumbers::Themes::Tailwind::Avatar::VARIANTS.each do |key, css_class|
      assert_equal css_class, @theme.avatar_variants.fetch(key)
    end
  end

  def test_avatar_image_returns_classes_to_fill_container
    result = @theme.resolve(:avatar_image)[:classes]

    assert_includes result, "w-full"
    assert_includes result, "h-full"
    assert_includes result, "object-cover"
  end
end
