# frozen_string_literal: true

require_relative "../application_system_test_case"

class CalendarSystemTest < ApplicationSystemTestCase
  # ── Stimulus controller ──────────────────────────────────────────────
  def test_renders_calendar_with_stimulus_controller
    visit "/components/calendar"

    assert_selector "[data-controller='calendar-month']"
  end

  # ── Navigation ───────────────────────────────────────────────────────
  def test_renders_previous_month_button
    visit "/components/calendar"

    assert_selector "button[data-calendar-month-target='previous'][aria-label='Previous Month']"
  end

  def test_renders_next_month_button
    visit "/components/calendar"

    assert_selector "button[data-calendar-month-target='next'][aria-label='Next Month']"
  end

  def test_navigation_buttons_contain_svg_icons
    visit "/components/calendar"

    assert_selector "button[data-calendar-month-target='previous'] svg"
    assert_selector "button[data-calendar-month-target='next'] svg"
  end

  # ── Header targets ───────────────────────────────────────────────────
  def test_renders_month_target
    visit "/components/calendar"

    assert_selector "[data-calendar-month-target='month']"
  end

  def test_renders_year_target
    visit "/components/calendar"

    assert_selector "[data-calendar-month-target='year']"
  end

  # ── Grid targets ─────────────────────────────────────────────────────
  def test_renders_days_of_week_grid
    visit "/components/calendar"

    assert_selector "[data-calendar-month-target='daysOfWeek']"
  end

  def test_renders_days_of_month_grid_with_role
    visit "/components/calendar"

    assert_selector "[data-calendar-month-target='daysOfMonth'][role='grid']"
  end

  # ── Accessibility ────────────────────────────────────────────────────
  def test_passes_wcag
    visit "/components/calendar"

    assert_accessible
  end
end
