# frozen_string_literal: true

require "pathname"

module StimulusPlumbers
  module Generators
    module TokensDirective
      GEM_ROOT            = File.expand_path("../../..", __dir__)
      TOKENS_CSS_REL_PATH = "app/assets/stylesheets/stimulus_plumbers/tokens.css"

      module_function

      def directive(from:)
        path = Pathname.new(GEM_ROOT).join(TOKENS_CSS_REL_PATH)
        rel  = path.relative_path_from(Pathname.new(from))
        %(@import "#{rel}";)
      end

      def stale_pattern
        %r{@import "[^"]*#{Regexp.escape(TOKENS_CSS_REL_PATH)}";}
      end
    end
  end
end
