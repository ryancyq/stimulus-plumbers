# frozen_string_literal: true

ENV["RAILS_ENV"] = "test"
require_relative "../sandbox/config/environment"

require "minitest/autorun"
require "capybara"
require "capybara/minitest"
require "capybara/cuprite"
require "stimulus_plumbers"

Capybara.register_driver(:cuprite) do |app|
  headless = ENV["HEADLESS"] != "false"
  Capybara::Cuprite::Driver.new(app, window_size: [1200, 800], headless: headless)
end

class ApplicationSystemTestCase < Minitest::Test
  include Capybara::DSL
  include Capybara::Minitest::Assertions

  def setup
    Capybara.current_driver = :cuprite
    Capybara.app = Rails.application
  end

  def teardown
    Capybara.reset_sessions!
    Capybara.use_default_driver
  end

  def assert_accessible
    violations = page.evaluate_async_script(<<~JS)
      var done = arguments[arguments.length - 1];
      axe.run(function(err, results) {
        done(err ? [] : results.violations);
      });
    JS
    assert violations.empty?,
      "Expected no axe violations, but found #{violations.size}:\n" +
      violations.map { |v| "  [#{v["id"]}] #{v["description"]}" }.join("\n")
  end
end
