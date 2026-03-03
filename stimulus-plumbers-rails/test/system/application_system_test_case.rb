# frozen_string_literal: true

ENV["RAILS_ENV"] = "test"
require_relative "../sandbox/config/environment"

require "minitest/autorun"
require "capybara"
require "capybara/minitest"
require "capybara/cuprite"
require "capybara_screenshot_diff/minitest"
require "rodiff"
require "stimulus_plumbers"
require_relative "rodiff_driver"

Capybara::Screenshot.save_path = "tmp/screenshots/baselines"
Capybara::Screenshot::Diff.driver = :rodiff

Capybara.register_driver(:cuprite) do |app|
  headless = ENV["HEADLESS"] != "false"
  Capybara::Cuprite::Driver.new(
    app,
    window_size:     [1200, 800],
    headless:        headless,
    browser_options: { "no-sandbox" => nil }
  )
end

class ApplicationSystemTestCase < Minitest::Test
  include Capybara::DSL
  include Capybara::Minitest::Assertions
  include CapybaraScreenshotDiff::Minitest::Assertions

  def setup
    Capybara.current_driver = :cuprite
    Capybara.app = Rails.application
  end

  def teardown
    save_screenshot_on_failure
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

    assert_empty violations, axe_violation_message(violations)
  end

  private

  def save_screenshot_on_failure
    return if failures.empty?

    dir = "tmp/screenshots"
    FileUtils.mkdir_p(dir)
    path = "#{dir}/#{self.class.name}##{name}_#{Time.now.strftime("%Y%m%d%H%M%S")}.png"
    page.save_screenshot(path)
  end

  def axe_violation_message(violations)
    "Expected no axe violations, but found #{violations.size}:\n" +
      violations.map { |v|
        nodes = v["nodes"].map { |n| "    #{n["html"]}" }.join("\n")
        "  [#{v["id"]}] #{v["description"]}\n#{nodes}"
      }.join("\n")
  end
end
