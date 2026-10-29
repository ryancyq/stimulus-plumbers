# frozen_string_literal: true

require "test_helper"

class TailwindThemeTimelineTest < Minitest::Test
  include ThemeAssertions

  INDICATORS = %i[dot icon].product(%i[vertical horizontal]).freeze

  def setup
    @theme = StimulusPlumbers::Themes::TailwindTheme.new
  end

  # ── :timeline (track) ────────────────────────────────────────────────────────

  def test_vertical_track_stacks_items_in_a_column
    assert_includes classes_for(:timeline, orientation: :vertical), "flex-col"
  end

  def test_horizontal_track_lays_items_out_in_a_row
    result = classes_for(:timeline, orientation: :horizontal)

    assert_includes result, "flex"
    refute_includes result, "flex-col"
  end

  def test_vertical_track_line_is_in_the_border_color
    assert_includes classes_for(:timeline_track_line), "bg-(--sp-color-border)"
  end

  # ── :timeline_item ───────────────────────────────────────────────────────────

  def test_vertical_item_puts_the_indicator_beside_its_content
    result = classes_for(:timeline_item)

    assert_includes result, "flex"
    assert_includes result, "items-start"
  end

  def test_horizontal_item_shares_the_track_width
    assert_includes classes_for(:timeline_item, orientation: :horizontal), "flex-1"
  end

  def test_connector_is_a_hairline_in_the_border_color_hidden_after_the_last_item
    result = classes_for(:timeline_item_connector)

    assert_includes result, "h-px"
    assert_includes result, "bg-(--sp-color-border)"
    assert_includes result, "last:hidden"
  end

  # ── :timeline_item_indicator ──────────────────────────────────────────────────

  def test_dot_indicator_is_neutral_not_primary
    %i[vertical horizontal].each do |orientation|
      result = classes_for(:timeline_item_indicator, type: :dot, orientation: orientation)

      assert_includes result, "bg-(--sp-color-bg)"
      refute_includes result, "bg-(--sp-color-primary)"
    end
  end

  def test_icon_indicator_is_filled_with_primary
    %i[vertical horizontal].each do |orientation|
      result = classes_for(:timeline_item_indicator, type: :icon, orientation: orientation)

      assert_includes result, "bg-(--sp-color-primary)"
      assert_includes result, "text-(--sp-color-primary-fg)"
    end
  end

  def test_every_indicator_has_a_ring_halo_against_the_page_background
    INDICATORS.each do |type, orientation|
      result = classes_for(:timeline_item_indicator, type: type, orientation: orientation)

      assert_includes result, "ring-4", "expected a halo on the #{orientation} #{type} indicator"
      assert_includes result, "ring-(--sp-color-bg)", "expected the page background halo on the #{orientation} #{type} indicator"
    end
  end

  def test_every_indicator_is_in_flow_not_absolute
    INDICATORS.each do |type, orientation|
      refute_includes classes_for(:timeline_item_indicator, type: type, orientation: orientation), "absolute"
    end
  end

  def test_indicator_icon_slot_strokes_in_the_text_color
    assert_includes classes_for(:timeline_item_indicator_icon_slot), "stroke-current"
  end

  # ── :timeline_item_trigger / time / title / description ──────────────────────

  def test_trigger_has_semibold_typography_and_interactive_states
    result = classes_for(:timeline_item_trigger)

    assert_includes result, "font-semibold"
    assert_includes result, "hover:text-(--sp-color-primary)"
    assert_includes result, "focus-visible:ring-(length:--sp-focus-ring-width)"
    assert_includes result, "focus-visible:ring-(--sp-color-primary-ring)"
  end

  def test_default_time_is_small_muted_text
    result = classes_for(:timeline_item_time, type: :default)

    assert_includes result, "text-sm"
    assert_includes result, "text-(--sp-color-muted-fg)"
  end

  def test_badge_time_is_a_bordered_muted_chip_in_medium_weight
    result = classes_for(:timeline_item_time, type: :badge)

    assert_includes result, "bg-(--sp-color-bg-muted)"
    assert_includes result, "border-(--sp-color-border)"
    assert_includes result, "text-(--sp-color-fg)"
    assert_includes result, "text-xs"
    assert_includes result, "font-medium"
    assert_includes result, "rounded"
  end

  def test_title_is_semibold_base_text
    result = classes_for(:timeline_item_title)

    assert_includes result, "font-semibold"
    assert_includes result, "text-base"
  end

  def test_description_is_small_muted_text
    result = classes_for(:timeline_item_description)

    assert_includes result, "text-sm"
    assert_includes result, "text-(--sp-color-muted-fg)"
  end
end
