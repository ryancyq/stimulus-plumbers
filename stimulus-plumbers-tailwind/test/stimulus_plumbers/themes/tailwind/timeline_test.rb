# frozen_string_literal: true

require "test_helper"

class TailwindThemeTimelineTest < Minitest::Test
  def setup
    @theme = StimulusPlumbers::Themes::TailwindTheme.new
  end

  def classes_for(component, **args)
    @theme.resolve(component, **args)[:classes]
  end

  # ── :timeline (track) ────────────────────────────────────────────────────────

  def test_vertical_track_separates_items_with_gap_not_border
    result = classes_for(:timeline, orientation: :vertical)

    assert_includes result, "gap-y-10"
    refute_includes result, "border-s"
  end

  def test_horizontal_track_uses_flex
    result = classes_for(:timeline, orientation: :horizontal)

    assert_includes result, "flex"
    refute_includes result, "border-t"
    refute_includes result, "border-s"
  end

  # ── :timeline_item ────────────────────────────────────────────────────────────

  def test_vertical_item_lays_out_indicator_beside_content
    result = classes_for(:timeline_item)

    assert_includes result, "flex"
    assert_includes result, "items-start"
    refute_includes result, "ms-6"
    refute_includes result, "mb-10"
  end

  def test_vertical_item_does_not_use_margin_start_offset
    result = classes_for(:timeline_item, orientation: :vertical)

    assert_includes result, "flex"
    refute_includes result, "ms-6"
  end

  def test_item_horizontal_layout_grows
    result = classes_for(:timeline_item, orientation: :horizontal)

    assert_includes result, "flex-1"
    refute_includes result, "pt-4"
    refute_includes result, "ms-6"
  end

  # ── :timeline_item_indicator ──────────────────────────────────────────────────

  def test_dot_indicator_container_is_neutral_not_primary
    result = classes_for(:timeline_item_indicator, type: :dot)

    assert_includes result, "rounded-full"
    refute_includes result, "bg-(--sp-color-primary)"
  end

  def test_dot_indicator_fill_uses_dedicated_color_token
    result = classes_for(:timeline_item_indicator_dot)

    assert_includes result, "rounded-full"
    assert_includes result, "bg-(--sp-color-indicator)"
    refute_includes result, "bg-(--sp-color-primary)"
  end

  def test_icon_indicator_uses_primary_brand_background
    result = classes_for(:timeline_item_indicator, type: :icon)

    assert_includes result, "bg-(--sp-color-primary)"
    refute_includes result, "bg-(--sp-color-bg)"
  end

  # ── :timeline_item_trigger ────────────────────────────────────────────────────

  def test_trigger_has_semibold_typography_and_interactive_states
    result = classes_for(:timeline_item_trigger)

    assert_includes result, "font-semibold"
    assert_includes result, "hover:text-(--sp-color-primary)"
    assert_includes result, "focus-visible:ring-2"
  end

  # ── :timeline_item_time / title / description / detail / actions / heading ───

  def test_time_uses_small_muted_inline_text
    result = classes_for(:timeline_item_time)

    assert_includes result, "block"
    assert_includes result, "text-sm"
  end

  def test_title_uses_semibold_base_text
    result = classes_for(:timeline_item_title)

    assert_includes result, "font-semibold"
    assert_includes result, "text-base"
  end

  def test_description_uses_small_muted_text
    assert_includes classes_for(:timeline_item_description), "text-sm"
  end

  def test_detail_has_top_spacing
    assert_includes classes_for(:timeline_item_detail), "mt-2"
  end

  def test_actions_are_flex_wrapped_with_gap
    result = classes_for(:timeline_item_actions)

    assert_includes result, "flex"
    assert_includes result, "flex-wrap"
    assert_includes result, "gap-2"
  end

  def test_heading_has_bottom_spacing
    assert_includes classes_for(:timeline_item_heading), "mb-1"
  end

  def test_both_indicator_types_have_ring_halo_against_page_background
    %i[dot icon].each do |type|
      result = classes_for(:timeline_item_indicator, type: type)

      assert_includes result, "ring-4", "expected ring on #{type} indicator"
      assert_includes result, "ring-(--sp-color-bg)", "expected ring to use page background on #{type} indicator"
    end
  end

  def test_time_default_type_uses_small_muted_text
    result = classes_for(:timeline_item_time, type: :default)

    assert_includes result, "text-sm"
    refute_includes result, "rounded"
    refute_includes result, "px-1.5"
  end

  def test_time_badge_type_uses_pill_styling
    result = classes_for(:timeline_item_time, type: :badge)

    assert_includes result, "rounded"
    assert_includes result, "px-1.5"
    assert_includes result, "font-medium"
    refute_includes result, "text-sm"
  end

  def test_horizontal_track_has_no_top_border
    result = classes_for(:timeline, orientation: :horizontal)

    assert_includes result, "flex"
    refute_includes result, "border-t"
  end

  def test_horizontal_item_has_no_top_padding
    result = classes_for(:timeline_item, orientation: :horizontal)

    assert_includes result, "flex-1"
    refute_includes result, "pt-4"
  end

  def test_connector_spans_full_width_and_hides_on_last
    result = classes_for(:timeline_item_connector)

    assert_includes result, "w-full"
    assert_includes result, "h-px"
    assert_includes result, "last:hidden"
  end

  def test_content_wrapper_has_top_margin
    result = classes_for(:timeline_item_content)

    assert_includes result, "mt-3"
  end

  def test_horizontal_dot_indicator_is_in_flow_not_absolute
    result = classes_for(:timeline_item_indicator, type: :dot, orientation: :horizontal)

    assert_includes result, "shrink-0"
    refute_includes result, "absolute"
  end

  def test_horizontal_icon_indicator_has_ring_and_is_in_flow
    result = classes_for(:timeline_item_indicator, type: :icon, orientation: :horizontal)

    assert_includes result, "shrink-0"
    assert_includes result, "ring-4"
    refute_includes result, "absolute"
  end

  def test_vertical_dot_indicator_is_in_flow_not_absolute
    result = classes_for(:timeline_item_indicator, type: :dot, orientation: :vertical)

    refute_includes result, "absolute"
    assert_includes result, "ring-4"
    assert_includes result, "ring-(--sp-color-bg)"
  end

  def test_group_wrapper_has_vertical_spacing
    result = classes_for(:timeline_group)

    assert_includes result, "space-y-4"
  end

  def test_group_section_has_border_and_rounded_corners
    result = classes_for(:timeline_group_section)

    assert_includes result, "border"
    assert_includes result, "rounded-lg"
  end

  def test_group_section_date_is_semibold
    result = classes_for(:timeline_group_section_date)

    assert_includes result, "font-semibold"
  end

  def test_group_section_list_uses_divide_not_border_s
    result = classes_for(:timeline_group_section_list)

    assert_includes result, "divide-y"
    refute_includes result, "border-s"
  end

  def test_vertical_track_line_spans_full_height_with_border_color
    result = classes_for(:timeline_track_line)

    assert_includes result, "inset-y-0"
    assert_includes result, "bg-(--sp-color-border)"
  end

  def test_indicator_icon_slot_uses_sm_icon_size
    result = classes_for(:timeline_item_indicator_icon_slot)

    assert_includes result, "size-(--sp-icon-size-sm)"
    assert_includes result, "stroke-current"
  end
end
