# frozen_string_literal: true

require "test_helper"

class CalendarMonthsOfYearTest < ActionView::TestCase
  def render_year(**kwargs)
    parse_html(
      StimulusPlumbers::Components::Calendar.new(self).render(
        id: "cal", today: Date.new(2026, 9, 10), view: :year, navigation: :turbo, **kwargs
      )
    )
  end

  def test_year_heading_labels_a_grid_of_twelve_months
    doc = render_year

    assert_equal "2026", doc.at_css("h2").text
    assert_equal 12, doc.css("[data-calendar-target='period']").size
  end

  def test_each_month_zooms_in_to_its_month
    month = render_year.at_css("[data-date='2026-03-01']")

    assert_equal "March", month.text
    assert_equal "March 2026", month["aria-label"]
    assert_equal "?cal%5Bdisplayed%5D=2026-03-01&cal%5Bview%5D=month", month["href"]
  end

  def test_the_current_month_holds_the_tab_stop_and_marks_today
    doc = render_year

    assert_equal(["2026-09-01"], doc.css("[tabindex='0']").map { |month| month["data-date"] })
    assert_css doc, "[data-date='2026-09-01'][aria-current='date']"
  end

  def test_months_outside_the_range_are_unavailable_and_do_not_open
    doc = render_year(min: "2026-03-15")

    assert_css doc, "a[role='link'][aria-disabled='true'][data-date='2026-02-01']:not([href])"
    assert_css doc, "a[href][data-date='2026-03-01']:not([aria-disabled])"
  end

  def test_year_view_zooms_out_to_the_decade
    assert(render_year.css("a").any? { |link| link.text == "Choose year" })
  end
end
