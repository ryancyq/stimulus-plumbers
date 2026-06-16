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

  # month

  def test_month_has_calendar_month_controller
    assert_includes renderer.month, 'data-controller="calendar-month"'
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

    assert_includes html, "datepicker:navigated-&gt;calendar-month#draw"
  end

  # year

  def test_year_has_grid_role
    assert_includes renderer.year, 'role="grid"'
  end

  def test_year_has_calendar_year_controller
    assert_includes renderer.year, 'data-controller="calendar-year"'
  end

  def test_year_has_year_view_aria_label
    assert_includes renderer.year, 'aria-label="Year view"'
  end

  def test_year_is_hidden_by_default
    assert_includes renderer.year, "hidden"
  end

  def test_year_has_grid_target
    doc = parse_html(renderer.year)

    assert_css doc, "[data-calendar-year-target='grid'][role='rowgroup']"
  end

  def test_year_merges_extra_data_attributes
    html = renderer.year(data: { foo: "bar" })

    assert_includes html, 'data-foo="bar"'
  end

  # decade

  def test_decade_has_grid_role
    assert_includes renderer.decade, 'role="grid"'
  end

  def test_decade_has_calendar_decade_controller
    assert_includes renderer.decade, 'data-controller="calendar-decade"'
  end

  def test_decade_has_decade_view_aria_label
    assert_includes renderer.decade, 'aria-label="Decade view"'
  end

  def test_decade_is_hidden_by_default
    assert_includes renderer.decade, "hidden"
  end

  def test_decade_has_grid_target
    doc = parse_html(renderer.decade)

    assert_css doc, "[data-calendar-decade-target='grid'][role='rowgroup']"
  end

  def test_decade_merges_extra_data_attributes
    html = renderer.decade(data: { foo: "bar" })

    assert_includes html, 'data-foo="bar"'
  end
end
