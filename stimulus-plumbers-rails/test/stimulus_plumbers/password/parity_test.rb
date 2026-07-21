# frozen_string_literal: true

require "test_helper"
require "json"

class PasswordParityTest < ActiveSupport::TestCase
  FIXTURE = File.expand_path("../../../../stimulus-plumbers/tests/fixtures/password_rules.json", __dir__)

  # Rebuild a Requirements from raw wire descriptors so the exact fixture rules are
  # evaluated through the same satisfies?/evaluate path the DSL produces. @enforced_options
  # is set to {} (not nil) so enforced? is true and descriptors are emitted; the built-ins
  # are all absent from {} so only the fixture's @custom descriptors are evaluated.
  def requirements_for(rules)
    req = StimulusPlumbers::Password::Requirements.new
    req.instance_variable_set(:@enforced_options, {})
    req.instance_variable_set(:@custom, custom_from(rules))
    req
  end

  def custom_from(rules)
    rules.to_h do |rule|
      [rule["key"].to_sym, { pattern: rule["pattern"], min: rule["min"], max: rule["max"], label: rule["key"] }]
    end
  end

  JSON.parse(File.read(FIXTURE)).each do |fixture|
    define_method("test_parity_#{fixture["name"].gsub(%r{\W+}, "_")}") do
      req = requirements_for(fixture["rules"])
      result = req.evaluate(fixture["password"])
      expected = fixture["expected"]["rules"].transform_keys(&:to_sym)

      assert_equal expected, result[:rules]
      assert_equal fixture["expected"]["valid"], req.valid?(fixture["password"])
    end
  end

  # Closes the DSL->JS seam: the parity fixtures prove JS-from-wire == Ruby-from-wire;
  # this proves Ruby-from-DSL == Ruby-from-wire, so to_stimulus is a lossless serialization
  # of the evaluable rule set. JSON round-trip mirrors what the component ships to the client.
  def test_to_stimulus_round_trips_losslessly_through_the_json_wire
    req = StimulusPlumbers::Password::Requirements.build do |r|
      r.enforce(min_length: 8, max_length: 64, uppercase: true, digit: 2)
      r.rule(:no_spaces, "No spaces", pattern: %r{\s}, negate: true)
    end
    rebuilt = requirements_for(JSON.parse(req.to_stimulus[:rules].to_json))

    ["Abcdef12", "ab", "A B123456", "", "ABCDEFGH"].each do |password|
      assert_equal(
        req.evaluate(password)[:rules],
        rebuilt.evaluate(password)[:rules],
        "wire round-trip diverged for #{password.inspect}"
      )
    end
  end
end
