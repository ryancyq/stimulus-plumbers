# frozen_string_literal: true

require_relative "application"

require "stimulus_plumbers_tailwind"

StimulusPlumbers.configure do |c|
  c.theme.register(:tailwind, StimulusPlumbers::Themes::TailwindTheme)
  c.theme.use(:tailwind)
end

require_relative "environments/test"

Rails.application.initialize!
