# frozen_string_literal: true

require "rails/generators"
require "stimulus_plumbers/generators/css_entrypoint"
require "stimulus_plumbers/generators/tokens_directive"

module StimulusPlumbers
  module Generators
    class InstallGenerator < Rails::Generators::Base
      include StimulusPlumbers::Generators::CssEntrypoint

      def install
        css_file = entry_css_file(**css_file_lookup_options)
        return warn_entry_css_not_found(label: "CSS", **css_file_lookup_options) unless css_file

        apply_edit(
          css_file,
          TokensDirective.directive(from: File.dirname(css_file)),
          stale_pattern: TokensDirective.stale_pattern
        )
      end

      private

      def css_file_lookup_options
        {
          candidates: CssEntrypoint::ENTRY_CANDIDATES,
          env_var:    CssEntrypoint::STIMULUS_PLUMBERS_CSS_ENTRY
        }
      end
    end
  end
end
