# frozen_string_literal: true

require "pathname"

module StimulusPlumbers
  module Tailwind
    module Generators
      module AnimationsDirective
        ANIMATIONS_CSS_PATH = "app/assets/stylesheets/stimulus_plumbers/tailwind/animations.css"

        module_function

        def directive(from:, destination_root:)
          path = Pathname.new(destination_root).join(ANIMATIONS_CSS_PATH)
          rel  = path.relative_path_from(Pathname.new(from))
          rel  = "./#{rel}" unless rel.to_s.start_with?(".", "/")
          %(@import "#{rel}";)
        end

        # Anchors right after the core tokens.css import so the two asset
        # imports stay grouped, ahead of the tailwindcss import and @source lines.
        def anchor_pattern
          %r{@import "[^"]*tokens\.css";}
        end

        def stale_pattern
          %r{@import "[^"]*#{Regexp.escape(ANIMATIONS_CSS_PATH)}";}
        end
      end
    end
  end
end
