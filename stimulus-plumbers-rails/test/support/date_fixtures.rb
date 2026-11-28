# frozen_string_literal: true

require "json"

module DateFixtures
  DIRECTORY = File.expand_path("../../../stimulus-plumbers/tests/fixtures/date", __dir__)
  AVAILABILITY_KEYS = {
    "min" => :min, "max" => :max, "disabledDates" => :disabled_dates, "disabledWeekdays" => :disabled_weekdays,
    "disabledMonths" => :disabled_months, "disabledYears" => :disabled_years
  }.freeze

  module_function

  def fixture(name)
    JSON.parse(File.read(File.join(DIRECTORY, "#{name}.json")))
  end

  def availability(json)
    (json || {}).transform_keys(AVAILABILITY_KEYS)
  end
end
