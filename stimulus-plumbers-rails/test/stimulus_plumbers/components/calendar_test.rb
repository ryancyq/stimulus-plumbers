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

  def render_calendar(**kwargs)
    parse_html(renderer.render(id: "cal", today: Date.new(2026, 9, 10), **kwargs))
  end

  def test_render_is_a_calendar_with_the_given_id
    assert_equal "calendar", render_calendar.at_css("div#cal")["data-controller"]
  end

  def test_render_announces_from_a_status_region_outside_the_frame
    assert_css render_calendar, "#cal > [role='status'][data-calendar-target='status'] + div#cal_frame"
  end

  def test_render_is_a_label_free_template
    doc = render_calendar

    assert_css doc, "div#cal_frame[hidden] table[role='grid'][aria-labelledby='cal_heading']:empty"
    assert_equal "", doc.at_css("h2#cal_heading").text
    assert_equal(%w[previous zoom next], doc.css("button[data-navigation]").map { |button| button["data-navigation"] })
    assert_no_css doc, "[aria-label], turbo-frame"
  end

  def test_render_renders_templates_for_each_cell
    doc = render_calendar

    assert_css doc, "template[data-calendar-target='dateTemplate'] td button[type='button']"
    assert_css doc, "template[data-calendar-target='weekdayTemplate'] th"
    assert_css doc, "template[data-calendar-target='cellTemplate'] td"
  end

  def test_render_passes_what_the_controller_draws
    root = render_calendar(displayed: "2026-12-01", view: :year, first_day_of_week: 1).at_css("#cal")

    assert_equal "2026-12-01", root["data-calendar-displayed-value"]
    assert_equal "year", root["data-calendar-view-value"]
    assert_equal "2026-09-10", root["data-calendar-today-value"]
    assert_equal "en", root["data-calendar-locale-value"]
    assert_equal "1", root["data-calendar-first-day-of-week-value"]
    assert_equal "Previous month", JSON.parse(root["data-calendar-labels-value"])["previousMonth"]
  end

  def test_render_falls_back_when_the_url_carries_invalid_values
    root = render_calendar(displayed: "not-a-date", view: "week").at_css("#cal")

    assert_equal "2026-09-10", root["data-calendar-displayed-value"]
    assert_equal "month", root["data-calendar-view-value"]
  end

  def test_render_selects_nothing_when_selected_is_not_a_date
    assert_nil render_calendar(selected: "2026-9-1").at_css("#cal")["data-calendar-selected-value"]
  end

  def test_render_accepts_today_as_a_date_key
    assert_equal "2026-09-10", render_calendar(today: "2026-09-10").at_css("#cal")["data-calendar-today-value"]
  end

  def test_render_exposes_its_settings_to_the_controller
    root = render_calendar(
      selected: "2026-09-15", selectable: true, min: "2026-09-03", disabled_weekdays: [0, 6]
    ).at_css("#cal")

    assert_equal "2026-09-15", root["data-calendar-selected-value"]
    assert_equal "true", root["data-calendar-selectable-value"]
    assert_equal "The calendar could not be loaded", JSON.parse(root["data-calendar-labels-value"])["error"]
    assert_equal "2026-09-03", root["data-calendar-min-value"]
    assert_equal "[0,6]", root["data-calendar-disabled-weekdays-value"]
  end

  def test_render_forwards_html_options_to_the_root
    assert_css render_calendar(class: "my-cal", data: { foo: "bar" }), "div.my-cal[data-foo='bar']"
  end

  def test_render_styles_each_part_from_the_theme
    parts = %i[calendar_status calendar_header calendar_heading calendar_navigation calendar_grid calendar_weekday
               calendar_cell calendar_date]
    original = StimulusPlumbers.config.theme.current
    StimulusPlumbers.config.theme.use(key_theme(parts))
    doc = render_calendar

    parts.each { |key| assert doc.at_css(".sp-#{key}"), "#{key} is unstyled" }
  ensure
    StimulusPlumbers.config.theme.use(original)
  end

  def test_render_rejects_invalid_options
    assert_raises(ArgumentError) { renderer.render(id: "") }
    assert_raises(ArgumentError) { render_calendar(first_day_of_week: 7) }
    assert_raises(ArgumentError) { render_calendar(today: "2026-9-10") }
    assert_raises(ArgumentError) { render_calendar(min: "2026-09-20", max: "2026-09-01") }
  end
end
