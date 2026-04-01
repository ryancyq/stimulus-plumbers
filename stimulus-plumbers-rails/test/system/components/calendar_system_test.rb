# frozen_string_literal: true

require_relative "../application_system_test_case"

class CalendarSystemTest < ApplicationSystemTestCase
  # ── Stimulus controller ──────────────────────────────────────────────
  def test_renders_calendar_with_stimulus_controller
    visit "/components/calendar"

    assert_selector "[data-controller='calendar-month']"
  end

  # ── Grid targets ─────────────────────────────────────────────────────
  def test_renders_days_of_week_grid
    visit "/components/calendar"

    assert_selector "[data-calendar-month-target='daysOfWeek']"
  end

  def test_renders_days_of_month_grid_with_role
    visit "/components/calendar"

    assert_selector "[data-calendar-month-target='daysOfMonth'][role='rowgroup']"
  end

  # ── Accessibility ────────────────────────────────────────────────────
  def test_passes_wcag
    visit "/components/calendar"

    assert_accessible
  end
end
