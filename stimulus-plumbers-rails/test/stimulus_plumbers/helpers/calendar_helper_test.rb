# frozen_string_literal: true

require "test_helper"

class CalendarHelperTest < ActionView::TestCase
  include StimulusPlumbers::Helpers::CalendarHelper

  def test_renders_calendar_month
    assert_includes sp_calendar_month, 'data-controller="calendar-month'
  end

  def test_sets_year_value_from_date
    html = sp_calendar_month(date: Date.new(2026, 4, 15))

    assert_includes html, 'data-calendar-month-year-value="2026"'
  end

  def test_sets_month_value_as_zero_indexed_from_date
    html = sp_calendar_month(date: Date.new(2026, 4, 15))

    assert_includes html, 'data-calendar-month-month-value="3"'
  end

  def test_sets_day_value_from_date
    html = sp_calendar_month(date: Date.new(2026, 4, 15))

    assert_includes html, 'data-calendar-month-day-value="15"'
  end

  def test_omits_date_values_when_date_is_nil
    html = sp_calendar_month

    assert_not_includes html, "calendar-month-year-value"
    assert_not_includes html, "calendar-month-month-value"
    assert_not_includes html, "calendar-month-day-value"
  end

  def test_merges_custom_data_attributes_with_date
    html = sp_calendar_month(date: Date.new(2026, 4, 1), data: { foo: "bar" })

    assert_includes html, "data-foo"
    assert_includes html, 'data-calendar-month-year-value="2026"'
  end
end
