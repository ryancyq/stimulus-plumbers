# frozen_string_literal: true

require_relative "icons/heroicon"
require_relative "icons/custom"
require "stimulus_plumbers/themes/icons/registry"

module StimulusPlumbers
  module Themes
    module Tailwind
      module Icon
        ALIASES = {
          "close"         => "x-mark",
          "download"      => "arrow-down-tray",
          "book"          => "book-open",
          "edit"          => "pencil",
          "email"         => "envelope",
          "calendar"      => "calendar-days",
          "external-link" => "arrow-top-right-on-square",
          "reveal"        => "eye",
          "save"          => "check",
          "grip-vertical" => "bars-3"
        }.freeze

        ICONS = StimulusPlumbers::Themes::Icons::Registry.new(
          sources: [Icons::Custom, Icons::Heroicon],
          aliases: ALIASES
        )

        SIZES = {
          sm: "size-(--sp-icon-size-sm)",
          md: "size-(--sp-icon-size-md)",
          lg: "size-(--sp-icon-size-lg)"
        }.freeze

        def icons
          ICONS
        end

        private

        def icon_classes(size: :lg)
          { classes: SIZES.fetch(size, SIZES[:lg]) }
        end
      end
    end
  end
end
