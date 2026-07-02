# frozen_string_literal: true

module StimulusPlumbers
  module Generators
    module TokensDirective
      GEM_ROOT            = File.expand_path("../../..", __dir__)
      TOKENS_CSS_REL_PATH = "app/assets/stylesheets/stimulus_plumbers/tokens.css"

      module_function

      def directive
        %(@import "#{GEM_ROOT}/#{TOKENS_CSS_REL_PATH}";)
      end

      def stale_pattern
        %r{@import "[^"]*#{Regexp.escape(TOKENS_CSS_REL_PATH)}";}
      end
    end
  end
end
