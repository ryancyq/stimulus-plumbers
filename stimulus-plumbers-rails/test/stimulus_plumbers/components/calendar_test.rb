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

  # render

  def render_calendar(navigation: :turbo, **kwargs)
    parse_html(renderer.render(id: "cal", today: Date.new(2026, 9, 10), navigation: navigation, **kwargs))
  end

  def test_render_is_a_calendar_with_the_given_id
    assert_css render_calendar, "div#cal[data-controller~='calendar']"
  end

  def test_render_announces_from_a_status_region_outside_the_frame
    doc = render_calendar

    assert_css doc, "#cal > [role='status'][data-calendar-target='status'] + turbo-frame#cal_frame"
    assert_css doc, "turbo-frame#cal_frame h2#cal_heading"
  end

  def test_stimulus_navigation_is_the_default_and_renders_a_label_free_template
    doc = parse_html(renderer.render(id: "cal"))

    assert_equal "calendar", doc.at_css("#cal")["data-controller"]
    assert_css doc, "div#cal_frame[hidden] table[role='grid'][aria-labelledby='cal_heading']:empty"
    assert_equal "", doc.at_css("h2#cal_heading").text
    assert_equal(%w[previous zoom next], doc.css("button[data-navigation]").map { |button| button["data-navigation"] })
    assert_no_css doc, "[aria-label], turbo-frame"
  end

  def test_stimulus_navigation_renders_templates_for_each_cell
    doc = parse_html(renderer.render(id: "cal"))

    assert_css doc, "template[data-calendar-target='dateTemplate'] td button[type='button']"
    assert_css doc, "template[data-calendar-target='weekdayTemplate'] th"
    assert_css doc, "template[data-calendar-target='cellTemplate'] td"
  end

  def test_stimulus_navigation_passes_what_the_controller_draws
    root = render_calendar(navigation: :stimulus, displayed: "2026-12-01", view: :year, first_day_of_week: 1).at_css("#cal")

    assert_equal "2026-12-01", root["data-calendar-displayed-value"]
    assert_equal "year", root["data-calendar-view-value"]
    assert_equal "2026-09-10", root["data-calendar-today-value"]
    assert_equal "en", root["data-calendar-locale-value"]
    assert_equal "1", root["data-calendar-first-day-of-week-value"]
    assert_equal "Previous month", JSON.parse(root["data-calendar-labels-value"])["previousMonth"]
  end

  def test_turbo_navigation_loads_periods_through_the_adapter
    root = render_calendar.at_css("#cal")

    assert_equal "calendar calendar-turbo", root["data-controller"]
    assert_includes root["data-action"].split, "calendar:navigate->calendar-turbo#onNavigate"
    assert_includes root["data-action"].split, "calendar-turbo:failed->calendar#onFailed"
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
    doc  = render_calendar(url: "/people/new?step=2")
    href = doc.at_css("a[aria-label='Next month']")["href"]

    assert_equal "/people/new?cal%5Bdisplayed%5D=2026-10-01&cal%5Bview%5D=month&step=2", href
    assert_equal "/people/new?step=2", doc.at_css("#cal")["data-calendar-url-value"]
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
    doc = render_calendar(displayed: "2026-12-01", view: "year")

    assert_equal "2026", doc.at_css("h2").text
  end

  def test_render_falls_back_when_the_url_carries_invalid_values
    doc = render_calendar(displayed: "not-a-date", view: "week")

    assert_equal "September 2026", doc.at_css("h2").text
  end

  def test_render_selects_nothing_when_selected_is_not_a_date
    assert_nil render_calendar(selected: "2026-9-1").at_css("#cal")["data-calendar-selected-value"]
  end

  def test_render_reads_a_time_as_its_date_in_the_time_zone
    Time.use_zone("Asia/Singapore") do
      calendar = render_calendar(selected: Time.utc(2026, 11, 3, 23, 30)).at_css("#cal")

      assert_equal "2026-11-04", calendar["data-calendar-selected-value"]
    end
  end

  def test_render_accepts_today_as_a_date_key
    assert_equal "September 2026", render_calendar(today: "2026-09-10").at_css("h2").text
  end

  def test_render_exposes_its_settings_to_the_controller
    root = render_calendar(
      selected: "2026-09-15", selectable: true, first_day_of_week: 1, min: "2026-09-03", disabled_weekdays: [0, 6]
    ).at_css("#cal")

    assert_equal "2026-09-15", root["data-calendar-selected-value"]
    assert_equal "true", root["data-calendar-selectable-value"]
    assert_equal "turbo", root["data-calendar-navigation-value"]
    assert_equal "The calendar could not be loaded", JSON.parse(root["data-calendar-labels-value"])["error"]
    assert_equal "2026-09-03", root["data-calendar-min-value"]
    assert_equal "[0,6]", root["data-calendar-disabled-weekdays-value"]
  end

  def test_render_marks_the_grid_with_the_period_it_shows
    grid = render_calendar(displayed: "2026-12-01", view: "year").at_css("table[role='grid']")

    assert_equal "2026-12-01", grid["data-displayed"]
    assert_equal "year", grid["data-view"]
  end

  def test_render_forwards_html_options_to_the_root
    assert_css render_calendar(class: "my-cal", data: { foo: "bar" }), "div.my-cal[data-foo='bar']"
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

  def test_render_rejects_invalid_options
    assert_raises(ArgumentError) { renderer.render(id: "") }
    assert_raises(ArgumentError) { render_calendar(navigation: :fetch) }
    assert_raises(ArgumentError) { render_calendar(first_day_of_week: 7) }
    assert_raises(ArgumentError) { render_calendar(today: "2026-9-10") }
    assert_raises(ArgumentError) { render_calendar(min: "2026-09-20", max: "2026-09-01") }
  end
end
