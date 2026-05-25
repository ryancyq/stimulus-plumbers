# frozen_string_literal: true

require_relative "icons/heroicon"
require_relative "icons/custom"
require "stimulus_plumbers/themes/icons/registry"

module StimulusPlumbers
  module Themes
    module Tailwind
      module Icon
        ALIASES = {
          "close"    => "x-mark",
          "calendar" => "calendar-days"
        }.freeze

        ICONS = StimulusPlumbers::Themes::Icons::Registry.new(
          sources: [Icons::Custom, Icons::Heroicon],
          aliases: ALIASES
        )

        def icons
          ICONS
        end

        private

        def icon_classes
          { classes: "size-(--sp-icon-default)" }
        end
      end
    end
  end
end
