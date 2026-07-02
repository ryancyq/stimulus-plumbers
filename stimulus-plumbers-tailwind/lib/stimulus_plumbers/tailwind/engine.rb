# frozen_string_literal: true

module StimulusPlumbers
  module Tailwind
    class Engine < ::Rails::Engine
      initializer "stimulus_plumbers_tailwind.register_theme" do
        StimulusPlumbers.configure do |c|
          c.theme.register(:tailwind, StimulusPlumbers::Themes::TailwindTheme)
          c.theme.use(:tailwind)
        end
      end

      rake_tasks do
        load File.join(__dir__, "../../tasks/stimulus_plumbers_tailwind.rake")
      end
    end
  end
end
