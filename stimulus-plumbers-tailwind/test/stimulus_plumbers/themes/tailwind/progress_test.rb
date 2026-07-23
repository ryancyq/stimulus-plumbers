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

  def test_fill_colors_by_intent_for_the_strength_ramp
    result = classes_for(:progress_bar_fill)

    assert_includes result, "[&[data-intent=danger]]:bg-(--sp-color-destructive)"
    assert_includes result, "[&[data-intent=warning]]:bg-(--sp-color-warning)"
    assert_includes result, "[&[data-intent=success]]:bg-(--sp-color-success)"
  end

  def test_segment_track_stays_static_while_indeterminate
    # The sliding chunk (a progress_bar_fill) carries the motion; the slot itself does not animate.
    refute_includes classes_for(:progress_segment), "[.sp-progress-indeterminate_&]:animate-pulse"
  end

  def test_ring_size_token_scales_the_ring
    assert_includes classes_for(:progress_ring, size: :lg), "size-16"
  end

  def test_ring_has_no_size_class_by_default
    refute_includes classes_for(:progress_ring), "size-16"
  end

  def test_segmented_lays_slots_out_in_a_row
    result = classes_for(:progress_segmented)

    assert_includes result, "flex"
    assert_includes result, "w-full"
  end

  def test_segment_slot_is_a_rounded_track_on_muted_background
    result = classes_for(:progress_segment)

    assert_includes result, "rounded-full"
    assert_includes result, "overflow-hidden"
    assert_includes result, "bg-(--sp-color-muted)"
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
