# frozen_string_literal: true

require "rails/engine"

module StimulusPlumbers
  class Engine < ::Rails::Engine
    isolate_namespace StimulusPlumbers

    config.autoload_paths << File.expand_path("../stimulus-plumbers", __dir__)
    config.i18n.load_path += Dir[File.expand_path("../../config/locales/*.{rb,yml}", __dir__)]

    initializer "stimulus_plumbers.helpers" do
      ActiveSupport.on_load(:action_view) do
        include StimulusPlumbers::Helpers
      end
    end

    rake_tasks do
      load File.join(__dir__, "../tasks/stimulus_plumbers.rake")
    end
  end
end
