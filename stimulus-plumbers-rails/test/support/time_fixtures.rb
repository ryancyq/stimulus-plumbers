# frozen_string_literal: true

require "json"

# The JS time core's fixtures, the source of truth for time rules.
module TimeFixtures
  DIRECTORY = File.expand_path("../../../stimulus-plumbers/tests/fixtures/time", __dir__)

  module_function

  def fixture(name)
    JSON.parse(File.read(File.join(DIRECTORY, "#{name}.json")))
  end

  def availability(json)
    (json || {}).transform_keys(&:to_sym)
  end
end
