# frozen_string_literal: true

require "test_helper"

class TailwindThemeTimelineTest < Minitest::Test
  def setup
    @theme = StimulusPlumbers::Themes::TailwindTheme.new
  end

  def classes_for(component, **args)
    @theme.resolve(component, **args)[:classes]
  end

  def test_timeline_vertical_includes_border_s
    assert_includes classes_for(:timeline, orientation: :vertical), "border-s"
  end

  def test_timeline_vertical_does_not_include_flex
    refute_includes classes_for(:timeline, orientation: :vertical), "flex"
  end

  def test_timeline_horizontal_includes_flex_and_border_t
    result = classes_for(:timeline, orientation: :horizontal)

    assert_includes result, "flex"
    assert_includes result, "border-t"
  end

  def test_timeline_horizontal_does_not_include_border_s
    refute_includes classes_for(:timeline, orientation: :horizontal), "border-s"
  end

  def test_timeline_item_defaults_to_vertical_classes
    result = classes_for(:timeline_item)

    assert_includes result, "ms-6"
    assert_includes result, "mb-10"
  end

  def test_timeline_item_vertical_includes_ms_6
    assert_includes classes_for(:timeline_item, orientation: :vertical), "ms-6"
  end

  def test_timeline_item_horizontal_includes_pt_4_and_flex_1
    result = classes_for(:timeline_item, orientation: :horizontal)

    assert_includes result, "pt-4"
    assert_includes result, "flex-1"
  end

  def test_timeline_item_horizontal_does_not_include_ms_6
    refute_includes classes_for(:timeline_item, orientation: :horizontal), "ms-6"
  end

  def test_timeline_indicator_dot_includes_rounded_full_and_size_3
    result = classes_for(:timeline_indicator, type: :dot)

    assert_includes result, "rounded-full"
    assert_includes result, "size-3"
  end

  def test_timeline_indicator_dot_does_not_include_size_7
    refute_includes classes_for(:timeline_indicator, type: :dot), "size-7"
  end

  def test_timeline_indicator_icon_includes_size_7_and_primary_bg
    result = classes_for(:timeline_indicator, type: :icon)

    assert_includes result, "size-7"
    assert_includes result, "bg-(--sp-color-primary)"
  end

  def test_timeline_indicator_icon_does_not_include_size_3
    refute_includes classes_for(:timeline_indicator, type: :icon), "size-3"
  end

  def test_timeline_trigger_includes_focus_visible_ring_2
    assert_includes classes_for(:timeline_trigger), "focus-visible:ring-2"
  end

  def test_timeline_trigger_includes_font_semibold
    assert_includes classes_for(:timeline_trigger), "font-semibold"
  end

  def test_timeline_trigger_includes_hover_text_primary
    assert_includes classes_for(:timeline_trigger), "hover:text-(--sp-color-primary)"
  end

  def test_timeline_actions_includes_flex_and_gap_2
    result = classes_for(:timeline_actions)

    assert_includes result, "flex"
    assert_includes result, "gap-2"
  end

  def test_timeline_actions_includes_flex_wrap
    assert_includes classes_for(:timeline_actions), "flex-wrap"
  end

  def test_timeline_time_includes_block_and_text_sm
    result = classes_for(:timeline_time)

    assert_includes result, "block"
    assert_includes result, "text-sm"
  end

  def test_timeline_title_includes_font_semibold_and_text_base
    result = classes_for(:timeline_title)

    assert_includes result, "font-semibold"
    assert_includes result, "text-base"
  end

  def test_timeline_description_includes_text_sm
    assert_includes classes_for(:timeline_description), "text-sm"
  end

  def test_timeline_detail_includes_mt_2
    assert_includes classes_for(:timeline_detail), "mt-2"
  end

  def test_timeline_trigger_wrapper_includes_mb_1
    assert_includes classes_for(:timeline_trigger_wrapper), "mb-1"
  end
end
