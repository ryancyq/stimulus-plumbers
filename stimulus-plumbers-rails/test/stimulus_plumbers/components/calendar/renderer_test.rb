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

  def test_month_contains_navigation
    html = renderer.month

    assert_includes html, "<button"
  end

  def test_month_contains_days_of_week
    html = renderer.month

    assert_includes html, 'data-calendar-month-target="daysOfWeek"'
  end

  def test_month_contains_days_of_month
    html = renderer.month

    assert_includes html, 'data-calendar-month-target="daysOfMonth"'
  end

  # navigation
  def test_navigation_renders_previous_button
    html = renderer.navigation

    assert_includes html, 'data-calendar-month-target="previous"'
  end

  def test_navigation_renders_next_button
    html = renderer.navigation

    assert_includes html, 'data-calendar-month-target="next"'
  end

  def test_navigation_renders_day_target
    html = renderer.navigation

    assert_includes html, 'data-calendar-month-target="day"'
  end

  def test_navigation_renders_month_target
    html = renderer.navigation

    assert_includes html, 'data-calendar-month-target="month"'
  end

  def test_navigation_renders_year_target
    html = renderer.navigation

    assert_includes html, 'data-calendar-month-target="year"'
  end

  # days_of_week
  def test_days_of_week_renders_div
    html = renderer.days_of_week

    assert_includes html, "<div"
  end

  def test_days_of_week_sets_target
    html = renderer.days_of_week

    assert_includes html, 'data-calendar-month-target="daysOfWeek"'
  end

  # days_of_month
  def test_days_of_month_renders_div
    html = renderer.days_of_month

    assert_includes html, "<div"
  end

  def test_days_of_month_sets_target
    html = renderer.days_of_month

    assert_includes html, 'data-calendar-month-target="daysOfMonth"'
  end

  def test_days_of_month_has_grid_role
    html = renderer.days_of_month

    assert_includes html, 'role="grid"'
  end
end
