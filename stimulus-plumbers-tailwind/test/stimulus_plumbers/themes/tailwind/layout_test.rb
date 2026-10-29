# frozen_string_literal: true

require "test_helper"

class TailwindThemeLayoutTest < Minitest::Test
  include ThemeAssertions

  def setup
    @theme = StimulusPlumbers::Themes::TailwindTheme.new
  end

  def test_divider_separator_is_a_hairline_in_the_border_color
    result = classes_for(:divider_separator)

    assert_includes result, "h-px"
    assert_includes result, "bg-(--sp-color-border)"
  end

  def test_popover_is_a_raised_bordered_surface_above_the_page
    result = classes_for(:popover)

    assert_includes result, "rounded-(--sp-radius-md)"
    assert_includes result, "border-(--sp-color-border)"
    assert_includes result, "bg-(--sp-color-bg)"
    assert_includes result, "shadow-(--sp-shadow-md)"
    assert_includes result, "z-(--sp-z-popover)"
    assert_includes result, "sp-popover"
  end

  def test_popover_maps_every_semantic_placement_to_logical_css
    expected = {
      block_end_start:   %w[block-end_span-inline-end flip-block,flip-inline,--sp-popover-fit],
      block_end:         %w[block-end flip-block,--sp-popover-fit],
      block_end_end:     %w[block-end_span-inline-start flip-block,flip-inline,--sp-popover-fit],
      block_start_start: %w[block-start_span-inline-end flip-block,flip-inline,--sp-popover-fit],
      block_start:       %w[block-start flip-block,--sp-popover-fit],
      block_start_end:   %w[block-start_span-inline-start flip-block,flip-inline,--sp-popover-fit],
      inline_start:      %w[inline-start flip-inline,--sp-popover-fit],
      inline_end:        %w[inline-end flip-inline,--sp-popover-fit]
    }

    expected.each do |placement, (area, fallbacks)|
      result = classes_for(:popover, placement: placement)

      assert_includes result, "[position-area:#{area}]"
      assert_includes result, "[position-try-fallbacks:#{fallbacks}]"
    end
  end

  def test_divider_label_is_medium_weight_on_one_line
    result = classes_for(:divider_label)

    assert_includes result, "whitespace-nowrap"
    assert_includes result, "font-medium"
  end

  def test_popover_trigger_text_is_medium_weight
    assert_includes classes_for(:popover_trigger), "font-medium"
  end

  def test_popover_trigger_is_a_bordered_transparent_control
    result = classes_for(:popover_trigger)

    assert_includes result, "border"
    assert_includes result, "border-(--sp-color-border)"
    assert_includes result, "bg-transparent"
  end

  def test_popover_trigger_shows_the_focus_ring
    result = classes_for(:popover_trigger)

    assert_includes result, "focus-visible:ring-(length:--sp-focus-ring-width)"
    assert_includes result, "focus-visible:ring-(--sp-focus-ring-color)"
  end

  def test_popover_trigger_tints_on_hover
    assert_includes classes_for(:popover_trigger), "hover:bg-(--sp-color-muted)"
  end
end
