# frozen_string_literal: true

ENV["RAILS_ENV"] = "test"
require_relative "sandbox/config/environment"

require "minitest/autorun"
require "minitest/mock"
require "nokogiri"

Dir[File.join(__dir__, "support/**/*.rb")].each { |f| require f }

ActionView::TestCase.include HtmlAssertions
ActionView::TestCase.include IconThemeHelper
ActionView::TestCase.include KeyThemeHelper
ActionView::TestCase.include StimulusPlumbers::Helpers::PlumberHelper

# Before Rails 7.0, ActionView::TestCase#request reads the view's @_request, which a test never sets.
ActionView::TestCase.attr_reader :request if Rails::VERSION::MAJOR < 7
