# frozen_string_literal: true

ENV["RAILS_ENV"] = "test"
require_relative "sandbox/config/environment"

require "minitest/autorun"
require "minitest/mock"
require "capybara/minitest"
require "nokogiri"
require "stimulus_plumbers"

Dir[File.join(__dir__, "support/**/*.rb")].each { |f| require f }

ActiveSupport::TestCase.include HtmlAssertions
ActionView::TestCase.include StimulusPlumbers::Helpers::PlumberHelper
