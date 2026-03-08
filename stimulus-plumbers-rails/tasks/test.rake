# frozen_string_literal: true

require "rake/testtask"

Rake::TestTask.new("test:unit") do |t|
  t.libs << "test"
  t.pattern = "test/stimulus_plumbers/**/*_test.rb"
  t.verbose = true
end

Rake::TestTask.new("test:system") do |t|
  t.libs << "test"
  t.pattern = "test/system/**/*_system_test.rb"
  t.verbose = true
end

task test: %w[test:unit test:system]
