# frozen_string_literal: true

require "test_helper"

class TailwindThemeIndicatorTest < Minitest::Test
  def setup
    @theme = StimulusPlumbers::Themes::TailwindTheme.new
  end

  def classes_for(component, **args)
    @theme.resolve(component, **args)[:classes]
  end

  def test_dot_returns_a_classes_string
    result = classes_for(:indicator, type: :dot, variant: :primary)

    assert_instance_of String, result
    assert_predicate result, :present?
  end

  def test_dot_is_in_flow_not_absolute
    result = classes_for(:indicator, type: :dot, variant: :primary)

    refute_includes result, "absolute"
  end

  StimulusPlumbers::Themes::Tailwind::Indicator::VARIANTS.each do |variant, css_class|
    define_method("test_dot_resolves_#{variant}_color") do
      assert_includes classes_for(:indicator, type: :dot, variant: variant), css_class
    end
  end

  def test_badge_type_uses_badge_shape_not_dot_shape
    result = classes_for(:indicator, type: :badge, variant: :primary)

    assert_includes result, "min-w-5"
    refute_includes result, "size-2.5"
  end

  def test_wrapper_establishes_relative_positioning_for_the_pulse_ring
    result = classes_for(:indicator_wrapper)

    assert_includes result, "relative"
  end

  def test_wrapper_uses_flex_and_alignment_not_margin
    result = classes_for(:indicator_wrapper)

    assert_includes result, "inline-flex"
    assert_includes result, "items-center"
    refute_includes result, "m-"
  end

  def test_pulse_ring_returns_a_classes_string
    result = classes_for(:indicator_pulse)

    assert_instance_of String, result
    assert_predicate result, :present?
  end

  def test_pulse_ring_overlays_via_absolute_inset_not_margin
    result = classes_for(:indicator_pulse)

    assert_includes result, "absolute"
    assert_includes result, "inset-0"
    refute_includes result, "-ms-"
  end

  def test_pulse_ring_animates_and_respects_reduced_motion
    result = classes_for(:indicator_pulse)

    assert_includes result, "animate-ping"
    assert_includes result, "motion-reduce:animate-none"
  end
end
