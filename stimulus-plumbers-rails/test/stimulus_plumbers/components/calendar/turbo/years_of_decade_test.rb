# frozen_string_literal: true

require "test_helper"

class CalendarTurboYearsOfDecadeTest < ActionView::TestCase
  def render_decade(**kwargs)
    parse_html(
      StimulusPlumbers::Components::Calendar.new(self).render(
        navigation: :turbo, id: "cal", today: Date.new(2026, 9, 10), view: :decade, **kwargs
      )
    )
  end

  def test_decade_heading_labels_the_years_with_a_neighbour_either_side
    doc   = render_decade
    years = doc.css("[data-calendar-target='period']").map(&:text)

    assert_equal "2020 – 2029", doc.at_css("h2").text
    assert_equal (2019..2030).map(&:to_s), years
    assert_css doc, "[data-date='2019-01-01'][data-outside='true']"
    assert_no_css doc, "[data-date='2020-01-01'][data-outside]"
  end

  def test_each_year_zooms_in_to_its_year_and_is_named_by_it
    year = render_decade.at_css("[data-date='2024-01-01']")

    assert_equal "?cal%5Bdisplayed%5D=2024-01-01&cal%5Bview%5D=year", year["href"]
    assert_nil year["aria-label"]
  end

  def test_disabled_years_are_unavailable_and_do_not_open
    assert_css render_decade(disabled_years: [2027]), "a[aria-disabled='true'][data-date='2027-01-01']:not([href])"
  end

  def test_the_decade_has_no_wider_view
    assert(render_decade.css("a").none? { |link| link.text.start_with?("Choose") })
  end

  def test_the_first_decade_stops_at_year_one
    doc = render_decade(displayed: "0005-06-01")

    assert_equal %w[1 2 3 4 5 6 7 8 9 10], doc.css("[data-calendar-target='period']").map(&:text)
    assert_css doc, "a[aria-label='Previous decade'][aria-disabled='true']:not([href])"
  end

  def test_the_last_decade_disables_next
    assert_css render_decade(displayed: "9995-06-01"), "a[aria-label='Next decade'][aria-disabled='true']:not([href])"
  end
end
