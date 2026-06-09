# frozen_string_literal: true

ENV["RAILS_ENV"] = "test"
require_relative "sandbox/config/environment"

require "minitest/autorun"
require "minitest/mock"
require "nokogiri"

Dir[File.join(__dir__, "support/**/*.rb")].each { |f| require f }

ActionView::TestCase.include HtmlAssertions
ActionView::TestCase.include IconThemeHelper
ActionView::TestCase.include StimulusPlumbers::Helpers::PlumberHelper
