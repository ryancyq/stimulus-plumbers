# frozen_string_literal: true

require "stimulus_plumbers"

require_relative "stimulus_plumbers/tailwind/version"
require_relative "stimulus_plumbers/themes/tailwind_theme"

if defined?(Rails::Engine)
  require_relative "stimulus_plumbers_tailwind/engine"
else
  StimulusPlumbers.configure do |c|
    c.theme.register(:tailwind, StimulusPlumbers::Themes::TailwindTheme)
  end
end
