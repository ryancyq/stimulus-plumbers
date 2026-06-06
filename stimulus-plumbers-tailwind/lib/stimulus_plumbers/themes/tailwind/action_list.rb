# frozen_string_literal: true

module StimulusPlumbers
  module Themes
    module Tailwind
      module ActionList
        ITEM_BASE = %w[
          flex items-center justify-start gap-(--sp-space-2) w-full
          px-(--sp-space-2) py-(--sp-space-1)
          rounded-(--sp-radius-sm) text-(length:--sp-text-sm)
          cursor-pointer select-none outline-none
          hover:bg-(--sp-color-muted) focus:bg-(--sp-color-muted) focus:text-(--sp-color-fg)
          aria-[current]:bg-(--sp-color-primary)/10 aria-[current]:text-(--sp-color-primary)
        ].freeze

        private

        def action_list_classes
          { classes: klasses("py-(--sp-space-1) divide-y divide-(--sp-color-border)") }
        end

        def action_list_section_classes
          { classes: klasses("py-(--sp-space-2)") }
        end

        def action_list_item_classes
          { classes: klasses(*ITEM_BASE) }
        end
      end
    end
  end
end
