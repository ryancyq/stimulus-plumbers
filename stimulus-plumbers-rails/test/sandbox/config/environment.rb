# frozen_string_literal: true

# Load the Rails application
require_relative "application"

require "stimulus_plumbers"

# Load the test environment configuration
require_relative "environments/test"

# Initialize the Rails application
Rails.application.initialize!
