# frozen_string_literal: true

require "pathname"

module StimulusPlumbers
  module Generators
    module TokensDirective
      TOKENS_CSS_PATH = "app/assets/stylesheets/stimulus_plumbers/tokens.css"

      module_function

      def directive(from:, destination_root:)
        path = Pathname.new(destination_root).join(TOKENS_CSS_PATH)
        rel  = path.relative_path_from(Pathname.new(from))
        rel  = "./#{rel}" unless rel.to_s.start_with?(".", "/")
        %(@import "#{rel}";)
      end

      def stale_pattern
        %r{@import "[^"]*#{Regexp.escape(TOKENS_CSS_PATH)}";}
      end
    end
  end
end
