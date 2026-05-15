# frozen_string_literal: true

require "minitest/test_task"

Minitest::TestTask.create("test:unit") do |t|
  t.test_globs = ["test/stimulus_plumbers/**/*_test.rb"]
  t.warning = false
end

Minitest::TestTask.create("test:accessibility") do |t|
  t.test_globs = ["test/accessibility/**/*_accessibility_test.rb"]
  t.warning = false
end

task test: %w[test:unit test:accessibility]
