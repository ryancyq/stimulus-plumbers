# frozen_string_literal: true

require "test_helper"

class CalendarRendererTest < ActionView::TestCase
  def renderer
    StimulusPlumbers::Components::Calendar::Renderer.new(self)
  end

  # attr_readers
  def test_exposes_template
    assert_equal self, renderer.template
  end

  def test_exposes_theme
    assert_equal StimulusPlumbers.config.theme, renderer.theme
  end

  # month
  def test_month_renders_div
    html = renderer.month

    assert_includes html, "<div"
  end

  def test_month_sets_calendar_month_controller
    html = renderer.month

    assert_includes html, 'data-controller="calendar-month"'
  end

  def test_month_sets_grid_role
    html = renderer.month

    assert_includes html, 'role="grid"'
  end

  def test_month_merges_extra_data_attributes
    html = renderer.month(data: { foo: "bar" })

    assert_includes html, "data-foo"
    assert_includes html, "bar"
  end

  def test_month_does_not_crash_without_data_kwarg
    assert_nothing_raised { renderer.month }
  end

  def test_month_merges_custom_class
    html = renderer.month(class: "my-cal")

    assert_includes html, "my-cal"
  end

  def test_month_contains_days_of_week
    html = renderer.month

    assert_includes html, 'data-calendar-month-target="daysOfWeek"'
  end

  def test_month_contains_days_of_month
    html = renderer.month

    assert_includes html, 'data-calendar-month-target="daysOfMonth"'
  end

  def test_month_accepts_parent_action_via_data
    html = renderer.month(data: { action: "datepicker:navigated->calendar-month#draw" })

    assert_includes html, 'data-action="datepicker:navigated-&gt;calendar-month#draw"'
  end

  # days_of_week
  def test_days_of_week_renders_div
    html = renderer.days_of_week

    assert_includes html, "<div"
  end

  def test_days_of_week_sets_target
    html = renderer.days_of_week(data: { "calendar-month-target" => "daysOfWeek" })

    assert_includes html, 'data-calendar-month-target="daysOfWeek"'
  end

  def test_days_of_week_renders_seven_columns
    html = renderer.days_of_week

    assert_equal 7, html.scan('role="columnheader"').length
  end

  # days_of_month
  def test_days_of_month_renders_div
    html = renderer.days_of_month

    assert_includes html, "<div"
  end

  def test_days_of_month_sets_target
    html = renderer.days_of_month(data: { "calendar-month-target" => "daysOfMonth" })

    assert_includes html, 'data-calendar-month-target="daysOfMonth"'
  end

  def test_days_of_month_renders_rows
    html = renderer.days_of_month

    assert_includes html, 'role="row"'
  end

  def test_days_of_month_renders_gridcells
    html = renderer.days_of_month

    assert_includes html, 'role="gridcell"'
  end

  def test_days_of_month_renders_multiple_of_seven_days
    html = renderer.days_of_month

    assert_equal 0, html.scan('role="gridcell"').length % 7
  end
end
