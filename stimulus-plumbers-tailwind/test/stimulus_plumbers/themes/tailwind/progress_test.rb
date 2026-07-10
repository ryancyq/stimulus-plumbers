# frozen_string_literal: true

require "test_helper"

class TailwindThemeProgressTest < Minitest::Test
  def setup
    @theme = StimulusPlumbers::Themes::TailwindTheme.new
  end

  def classes_for(component, **args)
    @theme.resolve(component, **args)[:classes]
  end

  def test_bar_returns_a_classes_string
    result = classes_for(:progress_bar)

    assert_instance_of String, result
    assert_predicate result, :present?
  end

  def test_bar_is_full_width_and_rounded
    result = classes_for(:progress_bar)

    assert_includes result, "w-full"
    assert_includes result, "rounded-full"
    assert_includes result, "overflow-hidden"
  end

  def test_bar_fill_uses_primary_color
    assert_includes classes_for(:progress_bar_fill), "bg-(--sp-color-primary)"
  end

  def test_bar_fill_slides_when_indeterminate
    result = classes_for(:progress_bar_fill)

    assert_includes result, "[.sp-progress-indeterminate_&]:animate-progress-slide"
  end

  def test_bar_fill_respects_reduced_motion
    result = classes_for(:progress_bar_fill)

    assert_includes result, "[.sp-progress-indeterminate_&]:motion-reduce:animate-none"
  end

  def test_ring_returns_a_classes_string
    result = classes_for(:progress_ring)

    assert_instance_of String, result
    assert_predicate result, :present?
  end

  def test_ring_starts_from_the_top_not_the_side
    assert_includes classes_for(:progress_ring), "-rotate-90"
  end

  def test_ring_spins_when_indeterminate
    result = classes_for(:progress_ring)

    assert_includes result, "[&.sp-progress-indeterminate]:animate-spin"
  end

  def test_meter_returns_a_classes_string
    result = classes_for(:progress_meter)

    assert_instance_of String, result
    assert_predicate result, :present?
  end

  def test_meter_styles_native_pseudo_elements
    result = classes_for(:progress_meter)

    assert_includes result, "[&::-webkit-meter-bar]:bg-(--sp-color-muted)"
    assert_includes result, "[&::-moz-meter-bar]:bg-(--sp-color-success)"
  end
end
