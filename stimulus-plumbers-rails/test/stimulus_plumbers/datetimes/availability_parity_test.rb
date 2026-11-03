# frozen_string_literal: true

require "test_helper"

# Runs the date-time core's availability fixtures through Datetimes::Availability.
class DatetimesAvailabilityParityTest < ActiveSupport::TestCase
  def build(json)
    StimulusPlumbers::Datetimes::Availability.new(**DatetimeFixtures.availability(json))
  end

  DatetimeFixtures.fixture("availability")["cases"].each_with_index do |rule, index|
    define_method("test_accepted_#{index}_#{rule["dateTime"].parameterize(separator: "_")}") do
      assert_equal rule["expect"], build(rule["availability"]).disabled?(rule["dateTime"]).present?
    end

    define_method("test_offered_#{index}_#{rule["dateTime"].parameterize(separator: "_")}") do
      availability = build(rule["availability"])
      date = StimulusPlumbers::Datetimes.date_of(rule["dateTime"])
      offered = !availability.date_availability.disabled?(date) &&
                !availability.day_availability(date).disabled?(rule["dateTime"][11, 5])

      assert_equal rule["expect"], !offered
    end
  end

  DatetimeFixtures.fixture("availability")["days"].each_with_index do |rule, index|
    define_method("test_day_#{index}_#{rule["date"].parameterize(separator: "_")}") do
      day = build(rule["availability"]).day_availability(Date.iso8601(rule["date"]))

      actual = { "step" => day.step, "ranges" => day.ranges }

      assert_equal rule["expect"], actual
    end
  end

  DatetimeFixtures.fixture("availability")["dates"].each do |rule|
    define_method("test_dates_#{rule["name"].parameterize(separator: "_")}") do
      dates = build(rule["availability"]).date_availability
      actual = {
        "min"              => dates.min&.iso8601,
        "max"              => dates.max&.iso8601,
        "disabledDates"    => dates.disabled_dates.map(&:iso8601),
        "disabledWeekdays" => dates.disabled_weekdays,
        "disabledMonths"   => dates.disabled_months,
        "disabledYears"    => dates.disabled_years
      }

      assert_equal rule["expect"], actual
    end
  end

  DatetimeFixtures.fixture("availability")["invalid"].each do |rule|
    define_method("test_invalid_#{rule["name"].parameterize(separator: "_")}") do
      availability = -> { build(rule["availability"]) }
      next assert_kind_of(StimulusPlumbers::Datetimes::Availability, availability.call) unless rule["option"]

      error = assert_raises(ArgumentError, &availability)

      assert_equal DatetimeFixtures.option(rule["option"]), error.message.split.first
    end
  end
end
