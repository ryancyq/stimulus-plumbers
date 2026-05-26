# frozen_string_literal: true

require_relative "icons/heroicon"
require_relative "icons/custom"
require_relative "icons/registry"

module StimulusPlumbers
  module Themes
    module Tailwind
      module Icon
        ALIASES = {
          "close"    => "x-mark",
          "calendar" => "calendar-days"
        }.freeze

        ICONS = Icons::Registry.new(aliases: ALIASES)

        def icons
          ICONS
        end

        private

        def icon_classes
          { classes: "size-6" }
        end
      end
    end
  end
end
