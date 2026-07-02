# frozen_string_literal: true

require "rails/generators"
require "stimulus_plumbers/generators/css_entrypoint"
require "stimulus_plumbers/generators/tokens_directive"

module StimulusPlumbers
  module Generators
    class InstallGenerator < Rails::Generators::Base
      include StimulusPlumbers::Generators::CssEntrypoint

      STIMULUS_PLUMBERS_CSS_FILE = CssEntrypoint::STIMULUS_PLUMBERS_CSS_FILE
      CSS_CANDIDATES             = %w[
        app/assets/stylesheets/application.tailwind.css
        app/assets/stylesheets/application.css
        app/javascript/entrypoints/application.css
      ].freeze

      def install
        css_file = entry_css_file(candidates: CSS_CANDIDATES, env_var: STIMULUS_PLUMBERS_CSS_FILE)
        unless css_file
          return warn_entry_css_not_found(candidates: CSS_CANDIDATES, env_var: STIMULUS_PLUMBERS_CSS_FILE, label: "CSS")
        end

        apply_edit(css_file, TokensDirective.directive, stale_pattern: TokensDirective.stale_pattern)
      end
    end
  end
end
