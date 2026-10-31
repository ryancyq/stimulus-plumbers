# frozen_string_literal: true

require "test_helper"

class TailwindThemeAvatarTest < Minitest::Test
  include ThemeAssertions

  VARIANT_SHADES = {
    amber:   "bg-amber-600",
    lime:    "bg-lime-600",
    sky:     "bg-sky-600",
    cyan:    "bg-cyan-600",
    teal:    "bg-teal-600",
    emerald: "bg-emerald-600",
    indigo:  "bg-indigo-600",
    fuchsia: "bg-fuchsia-600",
    rose:    "bg-rose-600",
    pink:    "bg-pink-600",
    violet:  "bg-violet-600",
    blue:    "bg-blue-600"
  }.freeze

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

  def test_each_avatar_variant_is_white_text_on_its_600_shade
    VARIANT_SHADES.each do |variant, shade|
      result = classes_for(:avatar, variant: variant)

      assert_includes result, "text-white", variant
      assert_includes result, shade, variant
    end
  end

  def test_avatar_image_covers_its_frame
    assert_includes classes_for(:avatar_image), "object-cover"
  end
end
