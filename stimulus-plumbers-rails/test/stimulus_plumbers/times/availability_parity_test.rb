# frozen_string_literal: true

require "test_helper"

# Runs the time core's availability fixtures through Times::Availability.
class TimesAvailabilityParityTest < ActiveSupport::TestCase
  def build(json)
    StimulusPlumbers::Times::Availability.new(**TimeFixtures.availability(json))
  end

  TimeFixtures.fixture("availability")["cases"].each_with_index do |rule, index|
    define_method("test_case_#{index}_#{rule["time"].delete(":")}") do
      assert_equal rule["expect"], build(rule["availability"]).disabled?(rule["time"]).present?
    end
  end

  TimeFixtures.fixture("availability")["hours"].each_with_index do |rule, index|
    define_method("test_hour_#{index}_#{rule["hour"]}") do
      assert_equal rule["expect"], build(rule["availability"]).hour_disabled?(rule["hour"])
    end
  end

  TimeFixtures.fixture("availability")["trims"].each_with_index do |rule, index|
    define_method("test_trim_#{index}_#{rule["time"].delete(":")}") do
      availability = build(rule["availability"]).trim(from: rule["from"], to: rule["to"])

      assert_equal rule["expect"], availability.disabled?(rule["time"]).present?
    end
  end

  TimeFixtures.fixture("availability")["invalid"].each do |rule|
    define_method("test_invalid_#{rule["name"].parameterize(separator: "_")}") do
      availability = -> { build(rule["availability"]) }
      next assert_kind_of(StimulusPlumbers::Times::Availability, availability.call) unless rule["option"]

      error = assert_raises(ArgumentError, &availability)

      assert_equal rule["option"], error.message.split.first
    end
  end
end
