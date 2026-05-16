# frozen_string_literal: true

require "rails/engine"

module StimulusPlumbers
  class Engine < ::Rails::Engine
    isolate_namespace StimulusPlumbers

    config.autoload_paths << File.expand_path("../stimulus-plumbers", __dir__)

    initializer "stimulus_plumbers.assets", after: :set_default_precompile do |app|
      app.config.assets.precompile += %w[stimulus_plumbers/tokens.css] if app.config.respond_to?(:assets)
    end

    initializer "stimulus_plumbers.helpers" do
      ActiveSupport.on_load(:action_view) do
        include StimulusPlumbers::Helpers
      end
    end
  end
end
