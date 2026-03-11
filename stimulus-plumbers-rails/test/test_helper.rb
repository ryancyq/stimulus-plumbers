# frozen_string_literal: true

ENV["RAILS_ENV"] = "test"
require_relative "sandbox/config/environment"

require "minitest/autorun"
require "minitest/mock"
require "capybara/minitest"
require "stimulus_plumbers"
