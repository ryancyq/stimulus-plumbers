# frozen_string_literal: true

require "test_helper"

class TailwindThemeProgressTest < Minitest::Test
  include ThemeAssertions

  def setup
    @theme = StimulusPlumbers::Themes::TailwindTheme.new
  end

  def test_bar_is_a_rounded_muted_track
    result = classes_for(:progress_bar)

    assert_includes result, "rounded-full"
    assert_includes result, "bg-(--sp-color-muted)"
  end

  def test_bar_fill_is_primary
    assert_includes classes_for(:progress_bar_fill), "bg-(--sp-color-primary)"
  end

  def test_bar_is_taller_when_a_readout_is_present
    assert_includes classes_for(:progress_bar, labelled: true), "h-5"
    refute_includes classes_for(:progress_bar, labelled: false), "h-5"
  end

  def test_bar_without_a_readout_keeps_the_slim_track
    assert_includes classes_for(:progress_bar, labelled: false), "h-2"
    refute_includes classes_for(:progress_bar, labelled: true), "h-2"
  end

  def test_readout_is_legible_over_both_track_and_fill
    result = classes_for(:progress_bar_value)

    assert_includes result,
                    "bg-[linear-gradient(to_right,var(--sp-color-primary-fg)_0_" \
                    "calc(var(--sp-progress-percent,0)*1%),var(--sp-color-fg)_0)]"
  end

  def test_outside_readout_is_in_flow_beside_the_track_in_the_primary_color
    result = classes_for(:progress_bar_value_outside)

    refute_includes result, "absolute"
    assert_includes result, "text-(--sp-color-primary)"
  end

  def test_readout_digits_do_not_jitter_in_either_placement
    %i[progress_bar_value progress_bar_value_outside].each do |key|
      assert_includes classes_for(key), "tabular-nums"
    end
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

  def test_ring_size_token_scales_the_ring
    assert_includes classes_for(:progress_ring, size: :lg), "size-16"
  end

  def test_ring_has_no_fixed_size_by_default
    refute_includes classes_for(:progress_ring), "size-16"
  end

  def test_segment_fill_keeps_the_indeterminate_animation_hooks
    result = classes_for(:progress_segment_fill)

    assert_includes result, "[.sp-progress-indeterminate_&]:animate-progress-slide"
    assert_includes result, "[.sp-progress-indeterminate_&]:motion-reduce:animate-none"
  end

  def test_segment_fill_colors_by_intent_like_the_bar_fill
    result = classes_for(:progress_segment_fill)

    assert_includes result, "bg-(--sp-color-primary)"
    assert_includes result, "[&[data-intent=danger]]:bg-(--sp-color-destructive)"
    assert_includes result, "[&[data-intent=success]]:bg-(--sp-color-success)"
  end

  def test_segment_slot_is_a_rounded_muted_track
    result = classes_for(:progress_segment)

    assert_includes result, "rounded-full"
    assert_includes result, "bg-(--sp-color-muted)"
  end

  def test_ring_starts_from_the_top_not_the_side
    assert_includes classes_for(:progress_ring), "-rotate-90"
  end

  def test_ring_spins_when_indeterminate
    result = classes_for(:progress_ring)

    assert_includes result, "[&.sp-progress-indeterminate]:animate-spin"
  end

  def test_meter_styles_native_pseudo_elements
    result = classes_for(:progress_meter)

    assert_includes result, "[&::-webkit-meter-bar]:bg-(--sp-color-muted)"
    assert_includes result, "[&::-moz-meter-bar]:bg-(--sp-color-success)"
  end
end
