# frozen_string_literal: true

require "json"

# The JS date-time core's fixtures, the source of truth for date-time rules.
module DatetimeFixtures
  DIRECTORY = File.expand_path("../../../stimulus-plumbers/tests/fixtures/datetime", __dir__)
  AVAILABILITY_KEYS = DateFixtures::AVAILABILITY_KEYS.merge("time" => :time).freeze

  module_function

  def fixture(name)
    JSON.parse(File.read(File.join(DIRECTORY, "#{name}.json")))
  end

  def availability(json)
    options = (json || {}).transform_keys(AVAILABILITY_KEYS)
    options[:time] &&= TimeFixtures.availability(options[:time])
    options
  end

  # An option named in a fixture, as Ruby names it.
  def option(name)
    scope, option = name.split(".", 2)
    option ? "#{scope}.#{option}" : AVAILABILITY_KEYS.fetch(scope).to_s
  end
end
