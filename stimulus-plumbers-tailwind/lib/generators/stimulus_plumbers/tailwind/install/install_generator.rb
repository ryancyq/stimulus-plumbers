# frozen_string_literal: true

require "rails/generators"
require "stimulus_plumbers/generators/css_entrypoint"
require "stimulus_plumbers/generators/tokens_directive"
require "stimulus_plumbers/tailwind/generators/sources_directive"

module StimulusPlumbers
  module Tailwind
    module Generators
      class InstallGenerator < Rails::Generators::Base
        include StimulusPlumbers::Generators::CssEntrypoint

        def install
          css_file = entry_css_file(**css_file_lookup_options)
          return warn_entry_css_not_found(label: "Tailwind CSS", **css_file_lookup_options) unless css_file

          apply_edit(
            css_file,
            StimulusPlumbers::Generators::TokensDirective.directive(from: File.dirname(css_file)),
            stale_pattern: StimulusPlumbers::Generators::TokensDirective.stale_pattern
          )
          apply_edit(
            css_file,
            SourcesDirective.directive(from: File.dirname(css_file)),
            anchor_pattern: SourcesDirective.anchor_pattern,
            stale_pattern:  SourcesDirective.stale_pattern
          )
        end

        private

        def css_file_lookup_options
          {
            candidates: StimulusPlumbers::Generators::CssEntrypoint::ENTRY_CANDIDATES,
            env_var:    StimulusPlumbers::Generators::CssEntrypoint::STIMULUS_PLUMBERS_CSS_ENTRY
          }
        end
      end
    end
  end
end
