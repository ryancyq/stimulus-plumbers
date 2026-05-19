# frozen_string_literal: true

module StimulusPlumbersTailwind
  class Engine < ::Rails::Engine
    initializer "stimulus_plumbers_tailwind.register_theme" do
      StimulusPlumbers.configure do |c|
        c.theme.register(:tailwind, StimulusPlumbers::Themes::TailwindTheme)
      end
    end
  end
end
