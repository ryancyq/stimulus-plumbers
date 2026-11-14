# frozen_string_literal: true

require "test_helper"

class CalendarTurboPeriodLinksTest < ActionView::TestCase
  def renderer
    StimulusPlumbers::Components::Calendar.new(self)
  end

  def render_calendar(**kwargs)
    parse_html(renderer.render(navigation: :turbo, id: "cal", today: Date.new(2026, 9, 10), **kwargs))
  end

  def calendar_period_path(date, level)
    "/periods/#{date.iso8601}/#{level}"
  end

  def test_links_from_a_lambda_given_the_date_and_level
    href = render_calendar(url: ->(date, level) { "/calendar/#{date.strftime("%Y/%m")}/#{level}" })
           .at_css("a[aria-label='Next month']")["href"]

    assert_equal "/calendar/2026/10/month", href
  end

  def test_links_from_a_symbol_naming_a_view_method
    href = render_calendar(url: :calendar_period_path).at_css("a[aria-label='Next month']")["href"]

    assert_equal "/periods/2026-10-01/month", href
  end

  def test_an_invalid_url_raises
    assert_raises(ArgumentError) { render_calendar(url: 1) }
  end

  def test_a_control_with_no_url_is_disabled
    link = render_calendar(url: ->(date, _level) { "/calendar" unless date.month == 10 })
           .at_css("[aria-label='Next month']")

    assert_equal "true", link["aria-disabled"]
    assert_equal "link", link["role"]
    assert_nil link["href"]
  end

  def test_a_cell_with_no_url_is_disabled
    doc = render_calendar(level: "year", url: ->(date, _level) { "/calendar" unless date.month == 3 })

    assert_css doc, "a[data-date='2026-03-01'][aria-disabled='true']:not([href])"
    assert_css doc, "a[data-date='2026-04-01'][href='/calendar'][data-level='month']"
  end

  def test_the_step_past_the_last_year_is_disabled
    assert_css render_calendar(displayed: "9999-12-01"), "a[aria-label='Next month'][aria-disabled='true']:not([href])"
  end

  def test_the_month_level_links_a_year_away
    link = render_calendar.at_css("a[data-navigation='previous-year']")

    assert_equal "Previous year", link["aria-label"]
    assert_equal "2025-09-01", link["data-date"]
    assert_equal "month", link["data-level"]
  end

  def test_other_levels_have_no_year_links
    assert_no_css render_calendar(level: "year"), "[data-navigation='previous-year']"
  end

  def test_links_name_their_date_and_level
    link = render_calendar.at_css("a[data-navigation='zoom']")

    assert_equal "year", link["data-level"]
    assert_equal "2026-09-10", link["data-date"]
  end
end
