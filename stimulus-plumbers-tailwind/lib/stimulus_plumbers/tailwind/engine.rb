# frozen_string_literal: true

module StimulusPlumbers
  module Tailwind
    class Engine < ::Rails::Engine
      initializer "stimulus-plumbers-tailwind.register_theme" do
        StimulusPlumbers.configure do |c|
          c.theme.register(:tailwind, StimulusPlumbers::Themes::TailwindTheme)
        end
      end
    end
  end
end
