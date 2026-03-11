# frozen_string_literal: true

require "test_helper"

class DatePickerHelperTest < ActionView::TestCase
  include StimulusPlumbers::Helpers::DatePickerHelper

  def test_renders_calendar_month_controller
    html = sp_date_picker_month

    assert_includes html, 'data-controller="calendar-month"'
  end

  def test_renders_navigation_targets
    html = sp_date_picker_month

    assert_includes html, 'data-calendar-month-target="previous"'
    assert_includes html, 'data-calendar-month-target="next"'
  end

  def test_renders_grid_targets
    html = sp_date_picker_month

    assert_includes html, 'data-calendar-month-target="daysOfWeek"'
    assert_includes html, 'data-calendar-month-target="daysOfMonth"'
  end

  def test_passes_html_options
    html = sp_date_picker_month(id: "picker")

    assert_includes html, 'id="picker"'
  end
end
