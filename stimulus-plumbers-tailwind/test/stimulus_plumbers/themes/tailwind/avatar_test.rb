# frozen_string_literal: true

require "test_helper"

class TailwindThemeAvatarTest < Minitest::Test
  include ThemeAssertions

  def setup
    @theme = StimulusPlumbers::Themes::TailwindTheme.new
  end

  def test_avatar_is_round
    assert_includes classes_for(:avatar), "rounded-(--sp-radius-full)"
  end

  def test_avatar_takes_the_dimension_of_each_size
    {
      sm: "size-(--sp-avatar-size-sm)",
      md: "size-(--sp-avatar-size-md)",
      lg: "size-(--sp-avatar-size-lg)"
    }.each do |size, dimension|
      assert_includes classes_for(:avatar, size: size), dimension, size
    end
  end

  def test_every_avatar_variant_is_white_text_on_its_600_shade
    @theme.avatar_variants.each do |variant, palette|
      assert_includes palette.split, "text-white"
      assert_includes palette.split, "bg-#{variant}-600"
    end
  end

  def test_avatar_variant_range_offers_every_variant_palette
    assert_equal @theme.avatar_variants.values, @theme.avatar_variant_range
  end

  def test_avatar_image_covers_its_frame
    assert_includes classes_for(:avatar_image), "object-cover"
  end
end
