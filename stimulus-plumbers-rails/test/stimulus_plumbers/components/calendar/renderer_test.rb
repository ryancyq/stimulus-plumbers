# frozen_string_literal: true

require "test_helper"

class CalendarRendererTest < ActionView::TestCase
  def renderer
    StimulusPlumbers::Components::Calendar.new(self)
  end

  def test_exposes_template
    assert_equal self, renderer.template
  end

  def test_exposes_theme
    assert_equal StimulusPlumbers.config.theme, renderer.theme
  end

  def test_month_has_calendar_month_controllers
    assert_includes renderer.month, 'data-controller="calendar-month calendar-month-observer"'
  end

  def test_month_has_click_action_for_observer_controller
    assert_includes renderer.month, "click-&gt;calendar-month-observer#select"
  end

  def test_month_has_grid_role
    assert_includes renderer.month, 'role="grid"'
  end

  def test_month_merges_extra_data_attributes
    html = renderer.month(data: { foo: "bar" })

    assert_includes html, "data-foo"
    assert_includes html, "bar"
  end

  def test_month_merges_custom_class
    assert_includes renderer.month(class: "my-cal"), "my-cal"
  end

  def test_month_has_days_of_week_target
    assert_includes renderer.month, 'data-calendar-month-target="daysOfWeek"'
  end

  def test_month_has_days_of_month_target
    assert_includes renderer.month, 'data-calendar-month-target="daysOfMonth"'
  end

  def test_month_accepts_parent_action_via_data
    html = renderer.month(data: { action: "datepicker:navigated->calendar-month#draw" })

    assert_includes html, "click-&gt;calendar-month-observer#select"
    assert_includes html, "datepicker:navigated-&gt;calendar-month#draw"
  end
end
