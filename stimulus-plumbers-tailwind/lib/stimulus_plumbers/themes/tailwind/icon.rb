# frozen_string_literal: true

module StimulusPlumbers
  module Themes
    module Tailwind
      module Icon
        ICONS = {
          "arrow-left"  => { d: "M10.5 19.5 3 12m0 0 7.5-7.5M3 12h18" },
          "arrow-right" => { d: "M13.5 4.5 21 12m0 0-7.5 7.5M21 12H3" }
        }.freeze

        def icons
          ICONS
        end

        private

        def icon_classes
          { classes: "" }
        end
      end
    end
  end
end
