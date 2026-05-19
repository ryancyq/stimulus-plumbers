# frozen_string_literal: true

require "test_helper"

class CalendarHelperTest < ActionView::TestCase
  include StimulusPlumbers::Helpers::CalendarHelper

  # ── rendering ─────────────────────────────────────────────────────────────

  def test_renders_calendar_month_controller
    assert_css parse_html(sp_calendar_month), "[data-controller~='calendar-month']"
  end

  # ── date values ───────────────────────────────────────────────────────────

  def test_sets_year_value_from_date
    assert_css parse_html(sp_calendar_month(date: Date.new(2026, 4, 15))),
               "[data-calendar-month-year-value='2026']"
  end

  def test_sets_month_value_as_zero_indexed_from_date
    assert_css parse_html(sp_calendar_month(date: Date.new(2026, 4, 15))),
               "[data-calendar-month-month-value='3']"
  end

  def test_sets_day_value_from_date
    assert_css parse_html(sp_calendar_month(date: Date.new(2026, 4, 15))),
               "[data-calendar-month-day-value='15']"
  end

  def test_omits_date_values_when_date_is_nil
    doc = parse_html(sp_calendar_month)

    assert_no_css doc, "[data-calendar-month-year-value]"
    assert_no_css doc, "[data-calendar-month-month-value]"
    assert_no_css doc, "[data-calendar-month-day-value]"
  end

  # ── html options ──────────────────────────────────────────────────────────

  def test_merges_custom_data_attributes_with_date
    doc = parse_html(sp_calendar_month(date: Date.new(2026, 4, 1), data: { foo: "bar" }))

    assert_css doc, "[data-foo='bar']"
    assert_css doc, "[data-calendar-month-year-value='2026']"
  end
end
