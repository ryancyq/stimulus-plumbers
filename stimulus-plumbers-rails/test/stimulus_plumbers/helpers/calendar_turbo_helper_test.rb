# frozen_string_literal: true

require "test_helper"

class CalendarTurboHelperTest < ActionView::TestCase
  include StimulusPlumbers::Helpers::CalendarTurboHelper

  def test_renders_html
    assert_includes sp_calendar_month_turbo, "<div"
  end

  def test_passes_date_to_renderer
    html = sp_calendar_month_turbo(date: Date.new(2026, 2, 1))

    # Feb 2026: starts Sunday, 28 days, no padding
    assert_equal 28, html.scan('role="gridcell"').length
  end

  def test_passes_today_to_renderer
    html = sp_calendar_month_turbo(date: Date.new(2026, 4, 1), today: Date.new(2026, 4, 10))

    assert_includes html, 'aria-current="date"'
  end

  def test_passes_selectable_to_renderer
    assert_includes sp_calendar_month_turbo(selectable: true), "<button"
  end

  def test_passes_selected_date_to_renderer
    html = sp_calendar_month_turbo(
      date:          Date.new(2026, 4, 1),
      selectable:    true,
      selected_date: Date.new(2026, 4, 10)
    )

    assert_includes html, 'aria-selected="true"'
  end

  def test_passes_show_other_months_to_renderer
    # Apr 2026 has padding days; with show_other_months they become aria-disabled gridcells
    html = sp_calendar_month_turbo(date: Date.new(2026, 4, 1), show_other_months: true)

    assert_includes html, 'aria-disabled="true"'
  end

  def test_passes_html_options_to_renderer
    html = sp_calendar_month_turbo(class: "my-cal", data: { foo: "bar" })

    assert_includes html, "my-cal"
    assert_includes html, "data-foo"
  end
end
