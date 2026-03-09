# frozen_string_literal: true

require "test_helper"

class DatePickerRendererTest < ActionView::TestCase
  def renderer
    StimulusPlumbers::Components::DatePicker::Renderer.new(self, StimulusPlumbers.config.theme)
  end

  # attr_readers
  def test_exposes_template
    assert_equal self, renderer.template
  end

  def test_exposes_theme
    assert_equal StimulusPlumbers.config.theme, renderer.theme
  end

  # month
  def test_month_renders_div_with_stimulus_controller
    html = renderer.month

    assert_includes html, 'data-controller="calendar-month"'
  end

  def test_month_renders_previous_button_with_target
    html = renderer.month

    assert_includes html, 'data-calendar-month-target="previous"'
  end

  def test_month_renders_next_button_with_target
    html = renderer.month

    assert_includes html, 'data-calendar-month-target="next"'
  end

  def test_month_renders_month_span_with_target
    html = renderer.month

    assert_includes html, 'data-calendar-month-target="month"'
  end

  def test_month_renders_year_span_with_target
    html = renderer.month

    assert_includes html, 'data-calendar-month-target="year"'
  end

  def test_month_renders_days_of_week_grid_with_target
    html = renderer.month

    assert_includes html, 'data-calendar-month-target="daysOfWeek"'
  end

  def test_month_renders_days_of_month_grid_with_role_grid
    html = renderer.month

    assert_includes html, 'data-calendar-month-target="daysOfMonth"'
    assert_includes html, 'role="grid"'
  end

  def test_month_renders_navigation_arrows
    html = renderer.month

    assert_includes html, "<svg"
    assert_includes html, "<path"
  end

  def test_month_passes_html_options
    html = renderer.month(id: "my-picker", class: "cal")

    assert_includes html, 'id="my-picker"'
    assert_includes html, "cal"
  end

  def test_month_merges_data_attributes
    html = renderer.month(data: { action: "keydown->calendar-month#handleKey" })

    assert_includes html, 'data-controller="calendar-month"'
    assert_includes html, 'data-action="keydown-&gt;calendar-month#handleKey"'
  end
end
