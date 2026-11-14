# frozen_string_literal: true

require "test_helper"

class TailwindThemeCalendarTest < Minitest::Test
  include ThemeAssertions

  def setup
    @theme = StimulusPlumbers::Themes::TailwindTheme.new
  end

  def test_calendar_status_is_visually_hidden
    assert_includes classes_for(:calendar_status), "sr-only"
  end

  def test_calendar_heading_is_semibold_foreground_text
    result = classes_for(:calendar_heading)

    assert_includes result, "font-semibold"
    assert_includes result, "text-(--sp-color-fg)"
  end

  def test_calendar_navigation_and_dates_are_at_least_one_day_cell
    %i[calendar_navigation calendar_date].each do |key|
      assert_includes classes_for(key), "min-h-(--sp-calendar-day-size)"
      assert_includes classes_for(key), "min-w-(--sp-calendar-day-size)"
    end
  end

  def test_calendar_navigation_and_dates_show_the_focus_ring
    %i[calendar_navigation calendar_date].each do |key|
      assert_includes classes_for(key), "focus-visible:outline-(--sp-focus-ring-color)"
    end
  end

  def test_calendar_grid_dims_while_its_frame_loads
    assert_includes classes_for(:calendar_grid), "[[aria-busy=true]_&]:opacity-60"
  end

  def test_calendar_weekdays_are_muted
    assert_includes classes_for(:calendar_weekday), "text-(--sp-color-muted-fg)"
  end

  def test_calendar_today_is_bold_and_underlined
    result = classes_for(:calendar_date)

    assert_includes result, "aria-[current=date]:font-bold"
    assert_includes result, "aria-[current=date]:underline"
  end

  def test_calendar_selected_date_is_filled_with_primary
    result = classes_for(:calendar_date)

    assert_includes result, "[[aria-selected=true]>&]:bg-(--sp-color-primary)"
    assert_includes result, "[[aria-selected=true]>&]:text-(--sp-color-primary-fg)"
  end

  def test_calendar_selected_date_keeps_a_fill_in_forced_colors
    result = classes_for(:calendar_date)

    assert_includes result, "forced-colors:[[aria-selected=true]>&]:forced-color-adjust-none"
    assert_includes result, "forced-colors:[[aria-selected=true]>&]:bg-[Highlight]"
  end

  def test_calendar_adjacent_dates_are_muted
    assert_includes classes_for(:calendar_date), "data-outside:text-(--sp-color-muted-fg)"
  end

  def test_calendar_unavailable_dates_are_faded_and_struck_through
    result = classes_for(:calendar_date)

    assert_includes result, "aria-disabled:opacity-40"
    assert_includes result, "aria-disabled:line-through"
  end
end
