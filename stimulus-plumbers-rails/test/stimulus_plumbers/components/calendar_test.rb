# frozen_string_literal: true

require "test_helper"

class CalendarComponentTest < ActionView::TestCase
  def renderer
    StimulusPlumbers::Components::Calendar.new(self)
  end

  def test_exposes_template
    assert_equal self, renderer.template
  end

  def test_exposes_theme
    assert_equal StimulusPlumbers.config.theme.current, renderer.theme
  end

  def test_render_has_calendar_month_controllers
    assert_includes renderer.render, 'data-controller="calendar-month calendar-observer"'
  end

  def test_render_has_click_action_for_observer_controller
    assert_includes renderer.render, "click-&gt;calendar-observer#onSelect"
  end

  def test_render_has_grid_role
    assert_includes renderer.render, 'role="grid"'
  end

  def test_render_merges_extra_data_attributes
    html = renderer.render(data: { foo: "bar" })

    assert_includes html, "data-foo"
    assert_includes html, "bar"
  end

  def test_render_merges_custom_class
    assert_includes renderer.render(class: "my-cal"), "my-cal"
  end

  def test_render_has_days_of_week_target
    assert_includes renderer.render, 'data-calendar-month-target="daysOfWeek"'
  end

  def test_render_has_days_of_month_target
    assert_includes renderer.render, 'data-calendar-month-target="daysOfMonth"'
  end

  def test_render_accepts_parent_action_via_data
    html = renderer.render(data: { action: "datepicker:navigated->calendar-month#draw" })

    assert_includes html, "click-&gt;calendar-observer#onSelect"
    assert_includes html, "datepicker:navigated-&gt;calendar-month#draw"
  end
end
