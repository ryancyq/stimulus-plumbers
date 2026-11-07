# frozen_string_literal: true

require "test_helper"

class CalendarTurboDaysOfMonthTest < ActionView::TestCase
  def render_month(**kwargs)
    html = StimulusPlumbers::Components::Calendar.new(self).render(
      navigation: :turbo, id: "cal", today: Date.new(2026, 9, 10), first_day_of_week: 0, **kwargs
    )
    parse_html(html)
  end

  def test_grid_is_labelled_by_the_month_heading
    doc = render_month

    assert_equal "September 2026", doc.at_css("h2#cal_heading").text
    assert_css doc, "table[role='grid'][aria-labelledby='cal_heading'][data-calendar-target='grid']"
  end

  def test_weekday_headers_start_on_the_first_day_of_the_week_with_full_names
    headers = render_month(first_day_of_week: 1).css("thead th[scope='col']")

    assert_equal %w[Mon Tue Wed Thu Fri Sat Sun], headers.map(&:text)
    assert_equal "Monday", headers.first["abbr"]
  end

  def test_each_day_is_a_button_with_a_date_key_and_full_label
    day = render_month.at_css("td[role='gridcell'] button[data-date='2026-09-15']")

    assert_equal "15", day.text
    assert_equal "September 15, 2026", day["aria-label"]
    assert_equal "day", day["data-calendar-target"]
  end

  def test_exactly_one_day_is_in_the_tab_sequence
    doc = render_month(selected: Date.new(2026, 9, 15))

    assert_equal(["2026-09-15"], doc.css("[tabindex='0']").map { |day| day["data-date"] })
  end

  def test_a_selectable_month_marks_the_selected_cell
    doc = render_month(selected: Date.new(2026, 9, 15), selectable: true)

    assert_css doc, "td[aria-selected='true'] [data-date='2026-09-15']"
    assert_css doc, "td[aria-selected='false'] [data-date='2026-09-16']"
    assert_no_css doc, "table[aria-readonly]"
  end

  def test_a_display_only_month_is_read_only
    doc = render_month(selected: Date.new(2026, 9, 15))

    assert_css doc, "table[aria-readonly='true']"
    assert_no_css doc, "td[aria-selected]"
  end

  def test_today_is_marked_current_independently_of_selection
    doc = render_month(selected: Date.new(2026, 9, 15))

    assert_css doc, "[data-date='2026-09-10'][aria-current='date']"
    assert_no_css doc, "[data-date='2026-09-15'][aria-current]"
  end

  def test_constrained_days_are_unavailable
    doc = render_month(min: "2026-09-05", disabled_weekdays: [0])

    assert_css doc, "[data-date='2026-09-04'][aria-disabled='true']"
    assert_css doc, "[data-date='2026-09-13'][aria-disabled='true']"
    assert_no_css doc, "[data-date='2026-09-14'][aria-disabled]"
  end

  def test_adjacent_month_days_are_empty_cells_unless_shown
    hidden = render_month
    shown  = render_month(show_other_months: true)

    assert_no_css hidden, "[data-date='2026-08-30']"
    assert_css shown, "[data-date='2026-08-30'][data-outside='true']"
  end
end
