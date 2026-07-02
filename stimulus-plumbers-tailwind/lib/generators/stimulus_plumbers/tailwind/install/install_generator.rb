# frozen_string_literal: true

require "rails/generators"
require "stimulus_plumbers/generators/css_entrypoint"
require "stimulus_plumbers/generators/tokens_directive"

module StimulusPlumbers
  module Tailwind
    module Generators
      class InstallGenerator < Rails::Generators::Base
        include StimulusPlumbers::Generators::CssEntrypoint

        GEM_NAME          = "stimulus_plumbers_tailwind"
        LIB_DIR           = File.expand_path("../../../..", __dir__)
        TAILWIND_CSS_FILE = "TAILWIND_CSS_FILE"
        CSS_CANDIDATES    = %w[
          app/assets/stylesheets/application.tailwind.css
          app/assets/stylesheets/application.css
          app/javascript/entrypoints/application.css
        ].freeze

        def install
          css_file = entry_css_file(**css_file_lookup_options)
          return warn_entry_css_not_found(label: "Tailwind CSS", **css_file_lookup_options) unless css_file

          apply_edit(
            css_file,
            StimulusPlumbers::Generators::TokensDirective.directive,
            stale_pattern: StimulusPlumbers::Generators::TokensDirective.stale_pattern
          )
          apply_edit(
            css_file,
            source_directive,
            anchor_pattern: source_anchor_pattern,
            stale_pattern:  source_stale_pattern
          )
        end

        private

        def css_file_lookup_options
          {
            candidates:       CSS_CANDIDATES,
            env_var:          TAILWIND_CSS_FILE,
            fallback_env_var: StimulusPlumbers::Generators::CssEntrypoint::STIMULUS_PLUMBERS_CSS_FILE
          }
        end

        def source_directive
          %(@source "#{LIB_DIR}/**/*.rb";)
        end

        def source_anchor_pattern
          %r{@import "tailwindcss"[^;]*;}
        end

        def source_stale_pattern
          %r{@source "[^"]*#{Regexp.escape(GEM_NAME)}[^"]*";}
        end
      end
    end
  end
end
