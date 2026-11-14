# frozen_string_literal: true

require "test_helper"

class TailwindThemeIndicatorTest < Minitest::Test
  include ThemeAssertions

  def setup
    @theme = StimulusPlumbers::Themes::TailwindTheme.new
  end

  def test_dot_is_in_flow_not_absolute
    result = classes_for(:indicator, type: :dot, variant: :primary)

    refute_includes result, "absolute"
  end

  def test_dot_takes_the_color_of_each_variant
    {
      primary:     "bg-(--sp-color-primary)",
      secondary:   "bg-(--sp-color-secondary)",
      tertiary:    "bg-(--sp-color-muted-fg)",
      success:     "bg-(--sp-color-success)",
      destructive: "bg-(--sp-color-destructive)",
      warning:     "bg-(--sp-color-warning)",
      info:        "bg-(--sp-color-info)"
    }.each do |variant, color|
      assert_includes classes_for(:indicator, type: :dot, variant: variant), color, variant
    end
  end

  def test_badge_type_is_a_small_white_count_not_a_dot
    result = classes_for(:indicator, type: :badge, variant: :primary)

    assert_includes result, "min-w-5"
    assert_includes result, "text-white"
    assert_includes result, "text-(length:--sp-text-xs)"
    assert_includes result, "font-medium"
    refute_includes result, "size-2.5"
  end

  def test_pulse_ring_animates_and_respects_reduced_motion
    result = classes_for(:indicator_pulse)

    assert_includes result, "animate-ping"
    assert_includes result, "motion-reduce:animate-none"
  end
end
