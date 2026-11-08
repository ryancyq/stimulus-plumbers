# frozen_string_literal: true

require "test_helper"

# Runs the date core's grid and focus fixtures through Calendar::Turbo.
class CalendarTurboParityTest < ActionView::TestCase
  def render_month(month:, first_day_of_week: 0, displayed: nil, show_other_months: true, **kwargs)
    html = StimulusPlumbers::Components::Calendar.new(self).render(
      navigation:        :turbo,
      id:                "cal",
      displayed:         displayed || "#{month}-01",
      first_day_of_week: first_day_of_week,
      show_other_months: show_other_months,
      **kwargs
    )
    parse_html(html)
  end

  DateFixtures.fixture("grid")["cases"].each do |grid|
    define_method("test_grid_#{grid["month"]}_from_weekday_#{grid["firstDayOfWeek"]}") do
      weeks = render_month(month: grid["month"], first_day_of_week: grid["firstDayOfWeek"], today: Date.new(1900, 1, 1))
              .css("tbody tr").map { |row| row.css("[data-date]").map { |day| day["data-date"] } }

      assert_equal grid["weeks"], weeks
    end
  end

  DateFixtures.fixture("focus")["cases"].each do |focus|
    define_method("test_focus_#{focus["name"].parameterize(separator: "_")}") do
      doc = render_month(
        month:             focus["month"],
        first_day_of_week: focus.fetch("firstDayOfWeek", 0),
        show_other_months: focus.fetch("showOtherMonths", false),
        today:             focus["today"] ? Date.iso8601(focus["today"]) : Date.new(1900, 1, 1),
        selected:          focus["selected"],
        displayed:         focus["displayed"],
        **DateFixtures.availability(focus["availability"])
      )

      assert_equal([focus["expect"]].compact, doc.css("[tabindex='0']").map { |day| day["data-date"] })
    end
  end
end
