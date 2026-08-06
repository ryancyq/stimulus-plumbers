# frozen_string_literal: true

require_relative "../../application_accessibility_test_case"

class CalendarTurboAccessibilityTest < ApplicationAccessibilityTestCase
  # Each test covers a unique HTML output combination verified by axe.

  def test_passes_wcag_with_default_options
    # non-selectable spans, padding cells aria-hidden
    visit "/components/calendar/turbo"

    assert_accessible context: "#calendar"
  end

  def test_passes_wcag_with_selectable
    # button gridcells with aria-selected
    visit "/components/calendar/turbo?selectable=true"

    assert_accessible context: "#calendar"
  end

  def test_passes_wcag_with_other_months_visible
    # disabled other-month gridcells present alongside current-month spans
    visit "/components/calendar/turbo?show_other_months=true"

    assert_accessible context: "#calendar"
  end

  def test_passes_wcag_with_selectable_and_other_months_visible
    # button gridcells + disabled other-month gridcells
    visit "/components/calendar/turbo?selectable=true&show_other_months=true"

    assert_accessible context: "#calendar"
  end

  def test_passes_wcag_with_month_view
    # sp_calendar_turbo_month directly: days-of-month grid
    visit "/components/calendar/turbo?view=month"

    assert_accessible context: "#calendar"
  end

  def test_passes_wcag_with_year_view
    # sp_calendar_turbo_year directly: months-of-year grid
    visit "/components/calendar/turbo?view=year"

    assert_accessible context: "#calendar"
  end

  def test_passes_wcag_with_decade_view
    # sp_calendar_turbo_decade directly: years-of-decade grid
    visit "/components/calendar/turbo?view=decade"

    assert_accessible context: "#calendar"
  end

  def test_passes_wcag_with_selected_date
    # selectable grid with aria-selected="true" on the matching day cell
    visit "/components/calendar/turbo?date=2026-06-01&selectable=true&selected_date=2026-06-15"

    assert_accessible context: "#calendar"
  end

  def test_passes_wcag_with_date_range
    # Jun 2026: out-of-range current-month cells are disabled spans (non-selectable, the SSR default)
    visit "/components/calendar/turbo?date=2026-06-01&since=2026-06-05&till=2026-06-25"

    assert_accessible context: "#calendar"
  end

  def test_passes_wcag_with_date_range_selectable
    # Jun 2026: in-range cells are buttons, out-of-range cells are disabled spans
    visit "/components/calendar/turbo?date=2026-06-01&selectable=true&since=2026-06-05&till=2026-06-25"

    assert_accessible context: "#calendar"
  end

  def test_passes_wcag_with_date_range_and_other_months_visible
    # Apr 2026: all 4 cell states — current/other-month × in-range/out-of-range (selectable for richest ARIA)
    visit "/components/calendar/turbo?date=2026-04-01&selectable=true&since=2026-03-30&till=2026-04-20&show_other_months=true"

    assert_accessible context: "#calendar"
  end
end
