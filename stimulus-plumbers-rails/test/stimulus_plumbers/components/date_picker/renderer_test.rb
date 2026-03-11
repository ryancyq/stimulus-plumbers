# frozen_string_literal: true

require "test_helper"

class DatePickerRendererTest < ActionView::TestCase
  def renderer
    StimulusPlumbers::Components::DatePicker::Renderer.new(self)
  end

  # attr_readers
  def test_exposes_template
    assert_equal self, renderer.template
  end

  def test_exposes_theme
    assert_equal StimulusPlumbers.config.theme, renderer.theme
  end

  # datepicker
  def test_datepicker_renders_datepicker_controller
    html = renderer.datepicker

    assert_includes html, 'data-controller="datepicker"'
  end

  def test_datepicker_renders_calendar_month_controller
    html = renderer.datepicker

    assert_includes html, 'data-controller="calendar-month"'
  end

  def test_datepicker_wires_navigated_action_to_calendar_month_draw
    html = renderer.datepicker

    assert_includes html, "datepicker:navigated-&gt;calendar-month#draw"
  end

  # navigation — targets belong to datepicker controller
  def test_navigation_renders_previous_button_with_datepicker_target
    html = renderer.datepicker

    assert_includes html, 'data-datepicker-target="previous"'
  end

  def test_navigation_renders_next_button_with_datepicker_target
    html = renderer.datepicker

    assert_includes html, 'data-datepicker-target="next"'
  end

  def test_navigation_renders_day_target
    html = renderer.datepicker

    assert_includes html, 'data-datepicker-target="day"'
  end

  def test_navigation_renders_month_target
    html = renderer.datepicker

    assert_includes html, 'data-datepicker-target="month"'
  end

  def test_navigation_renders_year_target
    html = renderer.datepicker

    assert_includes html, 'data-datepicker-target="year"'
  end

  def test_navigation_renders_previous_aria_label
    html = renderer.datepicker

    assert_includes html, 'aria-label="Previous Month"'
  end

  def test_navigation_renders_next_aria_label
    html = renderer.datepicker

    assert_includes html, 'aria-label="Next Month"'
  end

  def test_navigation_renders_nav_landmark
    html = renderer.datepicker

    assert_includes html, "<nav"
  end

  def test_navigation_renders_arrows
    html = renderer.datepicker

    assert_includes html, "<svg"
  end

  # calendar grid — targets belong to calendar-month controller
  def test_datepicker_renders_days_of_week_with_calendar_month_target
    html = renderer.datepicker

    assert_includes html, 'data-calendar-month-target="daysOfWeek"'
  end

  def test_datepicker_renders_days_of_month_with_calendar_month_target
    html = renderer.datepicker

    assert_includes html, 'data-calendar-month-target="daysOfMonth"'
  end

  def test_datepicker_passes_html_options
    html = renderer.datepicker(id: "my-picker", class: "cal")

    assert_includes html, 'id="my-picker"'
    assert_includes html, "cal"
  end

  def test_datepicker_merges_data_attributes
    html = renderer.datepicker(data: { foo: "bar" })

    assert_includes html, 'data-controller="datepicker"'
    assert_includes html, "data-foo"
  end
end
