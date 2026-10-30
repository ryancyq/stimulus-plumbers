# frozen_string_literal: true

require "test_helper"
require "json"

# Runs the date core's fixtures through the Ruby renderer.
class CalendarParityTest < ActionView::TestCase
  FIXTURES = File.expand_path("../../../../../stimulus-plumbers/tests/fixtures/date", __dir__)
  AVAILABILITY_KEYS = {
    "min" => :min, "max" => :max, "disabledDates" => :disabled_dates, "disabledWeekdays" => :disabled_weekdays,
    "disabledMonths" => :disabled_months, "disabledYears" => :disabled_years
  }.freeze

  class << self
    def fixture(name)
      JSON.parse(File.read(File.join(FIXTURES, "#{name}.json")))
    end
  end

  def availability(json)
    (json || {}).transform_keys(AVAILABILITY_KEYS)
  end

  def render_month(month:, first_day_of_week: 0, displayed: nil, show_other_months: true, **kwargs)
    html = StimulusPlumbers::Components::Calendar.new(self).render(
      id:                "cal",
      navigation:        :turbo,
      displayed:         displayed || "#{month}-01",
      first_day_of_week: first_day_of_week,
      show_other_months: show_other_months,
      **kwargs
    )
    parse_html(html)
  end

  fixture("grid")["cases"].each do |grid|
    define_method("test_grid_#{grid["month"]}_from_weekday_#{grid["firstDayOfWeek"]}") do
      weeks = render_month(month: grid["month"], first_day_of_week: grid["firstDayOfWeek"], today: Date.new(1900, 1, 1))
              .css("tbody tr").map { |row| row.css("[data-date]").map { |day| day["data-date"] } }

      assert_equal grid["weeks"], weeks
    end
  end

  fixture("availability")["cases"].each_with_index do |rule, index|
    define_method("test_case_#{index}_#{rule["date"]}") do
      calendar = StimulusPlumbers::Components::Calendar::Availability.new(**availability(rule["availability"]))

      assert_equal rule["expect"], calendar.disabled?(Date.iso8601(rule["date"])).present?
    end
  end

  fixture("availability")["periods"].each_with_index do |rule, index|
    define_method("test_period_#{index}_#{rule["year"]}_#{rule["month"]}") do
      calendar = StimulusPlumbers::Components::Calendar::Availability.new(**availability(rule["availability"]))
      disabled = rule["month"] ? calendar.month_disabled?(rule["year"], rule["month"]) : calendar.year_disabled?(rule["year"])

      assert_equal rule["expect"], disabled.present?
    end
  end

  fixture("availability")["invalid"].each do |rule|
    define_method("test_invalid_#{rule["name"].parameterize(separator: "_")}") do
      build = -> { StimulusPlumbers::Components::Calendar::Availability.new(**availability(rule["availability"])) }
      next assert_kind_of(StimulusPlumbers::Components::Calendar::Availability, build.call) unless rule["option"]

      error = assert_raises(ArgumentError, &build)

      assert_equal AVAILABILITY_KEYS.fetch(rule["option"]).to_s, error.message.split.first
    end
  end

  fixture("focus")["cases"].each do |focus|
    define_method("test_focus_#{focus["name"].parameterize(separator: "_")}") do
      doc = render_month(
        month:             focus["month"],
        first_day_of_week: focus.fetch("firstDayOfWeek", 0),
        show_other_months: focus.fetch("showOtherMonths", false),
        today:             focus["today"] ? Date.iso8601(focus["today"]) : Date.new(1900, 1, 1),
        selected:          focus["selected"],
        displayed:         focus["displayed"],
        **availability(focus["availability"])
      )

      assert_equal([focus["expect"]].compact, doc.css("[tabindex='0']").map { |day| day["data-date"] })
    end
  end
end
