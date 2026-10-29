# frozen_string_literal: true

ENV["RAILS_ENV"] = "test"
require_relative "../sandbox/config/environment"

require "minitest/autorun"
require "capybara"
require "capybara/minitest"
require "capybara/cuprite"

Capybara.register_driver(:cuprite) do |app|
  headless = ENV["HEADLESS"] != "false"
  Capybara::Cuprite::Driver.new(
    app,
    window_size:     [1280, 720],
    headless:        headless,
    browser_options: { "no-sandbox" => nil }
  )
end

class ApplicationAccessibilityTestCase < Minitest::Test
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

  def assert_accessible(context:)
    violations = axe_violations(context)

    assert_empty violations, axe_violation_message(violations, context)
  end

  # Runs axe on every sandbox section of the current page and reports each failing section.
  def assert_sections_accessible
    sections = all("section.sb-section", visible: :all)

    refute_empty sections, "no sandbox sections on #{page.current_path}"
    failures = sections.filter_map { |section| section_violation_message(section) }

    flunk failures.join("\n") if failures.any?
  end

  # Types into the focused element without clicking it.
  def press(*keys)
    page.driver.browser.keyboard.type(*keys)
  end

  # Runs axe on `context` (a selector, or the whole document) and returns its violations.
  # Fails the test when axe itself errors, e.g. when `context` matches no element.
  def axe_violations(context = nil)
    result = page.evaluate_async_script(<<~JS, context)
      var context = arguments[0];
      var done = arguments[arguments.length - 1];
      axe.run(context || document, function(err, results) {
        done(err ? { error: err.message } : { violations: results.violations });
      });
    JS
    flunk "axe failed on #{context || "document"}: #{result["error"]}" if result["error"]

    result["violations"]
  end

  private

  # The section's axe violation message, or nil when it passes.
  def section_violation_message(section)
    id = section[:id].to_s
    flunk "a sandbox section on #{page.current_path} has no id" if id.empty?
    flunk "sandbox section ##{id} is hidden, so axe would skip it" unless section.visible?

    violations = axe_violations("##{id}")
    axe_violation_message(violations, "##{id}") if violations.any?
  end

  def axe_violation_message(violations, context)
    "Expected no axe violations in #{context || "document"}, but found #{violations.size}:\n" +
      violations.map { |v|
        nodes = v["nodes"].map { |n| "    #{n["html"]}" }.join("\n")
        "  [#{v["id"]}] #{v["description"]}\n#{nodes}"
      }.join("\n")
  end
end
