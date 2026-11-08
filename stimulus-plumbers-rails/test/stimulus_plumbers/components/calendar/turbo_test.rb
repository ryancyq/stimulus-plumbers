# frozen_string_literal: true

require "test_helper"

class CalendarTurboTest < ActionView::TestCase
  def renderer
    StimulusPlumbers::Components::Calendar.new(self)
  end

  def render_calendar(**kwargs)
    parse_html(renderer.render(navigation: :turbo, id: "cal", today: Date.new(2026, 9, 10), **kwargs))
  end

  def test_render_announces_from_a_status_region_outside_the_frame
    doc = render_calendar

    assert_css doc, "#cal > [role='status'][data-calendar-target='status'] + turbo-frame#cal_frame"
    assert_css doc, "turbo-frame#cal_frame h2#cal_heading"
  end

  def test_render_loads_periods_through_the_adapter
    container = render_calendar.at_css("#cal")

    assert_equal "calendar calendar-turbo", container["data-controller"]
    assert_equal "turbo", container["data-calendar-navigation-value"]
    assert_includes container["data-action"].split, "click->calendar#onClick"
    assert_includes container["data-action"].split, "calendar:navigate->calendar-turbo#onNavigate"
    assert_includes container["data-action"].split, "calendar-turbo:failed->calendar#onFailed"
  end

  def test_render_links_to_the_adjacent_periods_through_the_url
    links = render_calendar.css("a[aria-label]").to_h { |link| [link["aria-label"], link["href"]] }

    assert_equal "?cal%5Bdisplayed%5D=2026-08-01&cal%5Bview%5D=month", links["Previous month"]
    assert_equal "?cal%5Bdisplayed%5D=2026-10-01&cal%5Bview%5D=month", links["Next month"]
  end

  def test_render_zooms_out_to_the_year
    link = render_calendar.css("a").find { |a| a.text == "Choose month" }

    assert_equal "?cal%5Bdisplayed%5D=2026-09-10&cal%5Bview%5D=year", link["href"]
  end

  def test_render_links_from_a_given_url_keeping_its_query
    href = render_calendar(url: "/people/new?step=2").at_css("a[aria-label='Next month']")["href"]

    assert_equal "/people/new?cal%5Bdisplayed%5D=2026-10-01&cal%5Bview%5D=month&step=2", href
  end

  def test_render_links_stay_on_this_page_when_the_path_starts_with_slashes
    request.path = "//evil.example/people"
    href = render_calendar.at_css("a[aria-label='Next month']")["href"]

    assert_equal "/evil.example/people?cal%5Bdisplayed%5D=2026-10-01&cal%5Bview%5D=month", href
  end

  def test_render_links_keep_a_current_path_with_unescaped_characters
    request.path = "/people|archived"
    href = render_calendar.at_css("a[aria-label='Next month']")["href"]

    assert_equal "/people|archived?cal%5Bdisplayed%5D=2026-10-01&cal%5Bview%5D=month", href
  end

  def test_render_reads_displayed_and_view_as_the_url_carries_them
    assert_equal "2026", render_calendar(displayed: "2026-12-01", view: "year").at_css("h2").text
  end

  def test_render_falls_back_when_the_url_carries_invalid_values
    assert_equal "September 2026", render_calendar(displayed: "not-a-date", view: "week").at_css("h2").text
  end

  def test_render_marks_the_grid_with_the_period_it_shows
    grid = render_calendar(displayed: "2026-12-01", view: "year").at_css("table[role='grid']")

    assert_equal "2026-12-01", grid["data-displayed"]
    assert_equal "year", grid["data-view"]
  end

  def test_render_styles_each_part_from_the_theme
    parts = %i[calendar_status calendar_header calendar_heading calendar_navigation calendar_grid calendar_weekday
               calendar_cell calendar_date]
    original = StimulusPlumbers.config.theme.current
    StimulusPlumbers.config.theme.use(key_theme(parts))
    doc = render_calendar(selectable: true)

    parts.each { |key| assert doc.at_css(".sp-#{key}"), "#{key} is unstyled" }
  ensure
    StimulusPlumbers.config.theme.use(original)
  end
end
