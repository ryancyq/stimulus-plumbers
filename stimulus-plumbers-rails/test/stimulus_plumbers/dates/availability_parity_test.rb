# frozen_string_literal: true

require "test_helper"

# Runs the date core's availability fixtures through Dates::Availability.
class DatesAvailabilityParityTest < ActiveSupport::TestCase
  def build(json)
    StimulusPlumbers::Dates::Availability.new(**DateFixtures.availability(json))
  end

  DateFixtures.fixture("availability")["cases"].each_with_index do |rule, index|
    define_method("test_case_#{index}_#{rule["date"]}") do
      assert_equal rule["expect"], build(rule["availability"]).disabled?(Date.iso8601(rule["date"])).present?
    end
  end

  DateFixtures.fixture("availability")["periods"].each_with_index do |rule, index|
    define_method("test_period_#{index}_#{rule["year"]}_#{rule["month"]}") do
      rules    = build(rule["availability"])
      disabled = rule["month"] ? rules.month_disabled?(rule["year"], rule["month"]) : rules.year_disabled?(rule["year"])

      assert_equal rule["expect"], disabled.present?
    end
  end

  DateFixtures.fixture("availability")["invalid"].each do |rule|
    define_method("test_invalid_#{rule["name"].parameterize(separator: "_")}") do
      availability = -> { build(rule["availability"]) }
      next assert_kind_of(StimulusPlumbers::Dates::Availability, availability.call) unless rule["option"]

      error = assert_raises(ArgumentError, &availability)

      assert_equal DateFixtures::AVAILABILITY_KEYS.fetch(rule["option"]).to_s, error.message.split.first
    end
  end
end
