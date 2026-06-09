# frozen_string_literal: true

module StimulusPlumbers
  module Themes
    module Tailwind
      module ActionList
        ITEM_BASE = [
          *Control::BASE,
          "flex items-center gap-(--sp-space-2) w-full",
          "px-(--sp-space-2) py-(--sp-space-1)",
          "rounded-(--sp-radius-sm) text-(length:--sp-text-sm)",
          "cursor-pointer select-none",
          "text-(--sp-color-fg)",
          "focus-visible:ring-(--sp-color-primary-ring)",
          "hover:bg-(--sp-color-muted) focus:bg-(--sp-color-muted) focus:text-(--sp-color-fg)",
          "aria-[current]:bg-(--sp-color-primary)/10 aria-[current]:text-(--sp-color-primary)"
        ].freeze

        private

        def action_list_classes
          { classes: klasses("py-(--sp-space-1) divide-y divide-(--sp-color-border)") }
        end

        def action_list_section_classes
          { classes: klasses("py-(--sp-space-2)") }
        end

        def action_list_section_header_classes
          {
            classes: klasses(
              "block px-(--sp-space-2) pb-(--sp-space-1)",
              "text-(length:--sp-text-xs) font-semibold uppercase tracking-wider",
              "text-(--sp-color-muted-fg)"
            )
          }
        end

        def action_list_item_classes
          { classes: klasses(*ITEM_BASE) }
        end

        def action_list_item_icon_classes
          { classes: klasses("size-(--sp-control-size)", "stroke-current") }
        end
      end
    end
  end
end
