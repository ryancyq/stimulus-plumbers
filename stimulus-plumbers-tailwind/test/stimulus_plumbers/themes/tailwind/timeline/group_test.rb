# frozen_string_literal: true

require "test_helper"

class TailwindThemeTimelineGroupTest < Minitest::Test
  include ThemeAssertions

  def setup
    @theme = StimulusPlumbers::Themes::TailwindTheme.new
  end

  def test_group_section_is_a_bordered_muted_card
    result = classes_for(:timeline_group_section)

    assert_includes result, "bg-(--sp-color-bg-muted)"
    assert_includes result, "border-(--sp-color-border)"
    assert_includes result, "rounded-lg"
  end

  def test_group_section_date_is_semibold
    assert_includes classes_for(:timeline_group_section_date), "font-semibold"
  end

  def test_vertical_group_list_divides_events_in_the_border_color
    result = classes_for(:timeline_group_section_list)

    assert_includes result, "divide-y"
    assert_includes result, "divide-(--sp-color-border)"
  end

  def test_horizontal_group_list_lays_events_in_a_row_without_dividers
    result = classes_for(:timeline_group_section_list, orientation: :horizontal)

    assert_includes result, "flex"
    refute_includes result, "divide-y"
  end
end
