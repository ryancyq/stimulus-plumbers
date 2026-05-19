# frozen_string_literal: true

require_relative "application"

require "stimulus_plumbers_tailwind"

StimulusPlumbers.configure { |c| c.theme = :tailwind }

require_relative "environments/test"

Rails.application.initialize!
