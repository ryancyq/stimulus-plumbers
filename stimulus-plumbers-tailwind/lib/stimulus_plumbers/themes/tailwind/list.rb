# frozen_string_literal: true

module StimulusPlumbers
  module Themes
    module Tailwind
      module List
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

        ITEM_CONTENT_BASE = %w[
          flex flex-col flex-1 min-w-0
        ].freeze

        ITEM_TITLE_BASE = %w[
          text-(length:--sp-text-sm) font-medium text-(--sp-color-fg)
        ].freeze

        ITEM_DESCRIPTION_BASE = %w[
          text-(length:--sp-text-xs) text-(--sp-color-muted-fg)
        ].freeze

        SECTION_TITLE_BASE = %w[
          block px-(--sp-space-2) pb-(--sp-space-1)
          text-(length:--sp-text-xs) font-semibold uppercase tracking-wider
          text-(--sp-color-muted-fg)
        ].freeze

        SECTION_DESCRIPTION_BASE = %w[
          block px-(--sp-space-2) pb-(--sp-space-1)
          text-(length:--sp-text-xs) text-(--sp-color-muted-fg)
        ].freeze

        private

        def list_classes
          { classes: klasses("py-(--sp-space-1) divide-y divide-(--sp-color-border)") }
        end

        def list_section_classes
          { classes: klasses("py-(--sp-space-2)") }
        end

        def list_section_title_classes
          { classes: klasses(*SECTION_TITLE_BASE) }
        end

        def list_section_description_classes
          { classes: klasses(*SECTION_DESCRIPTION_BASE) }
        end

        def list_item_classes
          { classes: klasses(*ITEM_BASE) }
        end

        def list_item_icon_classes
          { classes: klasses("size-(--sp-control-size)", "stroke-current") }
        end

        def list_item_content_classes
          { classes: klasses(*ITEM_CONTENT_BASE) }
        end

        def list_item_title_classes
          { classes: klasses(*ITEM_TITLE_BASE) }
        end

        def list_item_description_classes
          { classes: klasses(*ITEM_DESCRIPTION_BASE) }
        end
      end
    end
  end
end
