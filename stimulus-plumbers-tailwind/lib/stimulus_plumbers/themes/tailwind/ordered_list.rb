# frozen_string_literal: true

module StimulusPlumbers
  module Themes
    module Tailwind
      module OrderedList
        # ── Item ──────────────────────────────────────────────────────────────
        ITEM_BASE = [
          *Control::BASE,
          "flex items-center gap-(--sp-space-2) w-full",
          "px-(--sp-space-2) py-(--sp-space-1)",
          "rounded-(--sp-radius-sm) text-(length:--sp-text-sm)",
          "text-(--sp-color-fg)",
          "focus-visible:ring-(--sp-color-primary-ring)",
          "aria-[current]:bg-(--sp-color-primary)/10 aria-[current]:text-(--sp-color-primary)"
        ].freeze

        HANDLE_BASE = %w[
          flex items-center justify-center shrink-0
          stroke-current
          text-(--sp-color-muted-fg)
          cursor-grab active:cursor-grabbing
          touch-none
        ].freeze

        CONTENT_BASE = %w[
          flex flex-col flex-1 min-w-0
        ].freeze

        TITLE_BASE = %w[
          text-(length:--sp-text-sm) font-medium text-(--sp-color-fg)
        ].freeze

        DESCRIPTION_BASE = %w[
          text-(length:--sp-text-xs) text-(--sp-color-muted-fg)
        ].freeze

        private

        def ordered_list_classes
          { classes: klasses("flex flex-col gap-(--sp-space-1) py-(--sp-space-1)") }
        end

        def ordered_list_item_classes
          { classes: klasses(*ITEM_BASE) }
        end

        def ordered_list_item_handle_classes
          { classes: klasses(*HANDLE_BASE) }
        end

        def ordered_list_item_content_classes
          { classes: klasses(*CONTENT_BASE) }
        end

        def ordered_list_item_title_classes
          { classes: klasses(*TITLE_BASE) }
        end

        def ordered_list_item_description_classes
          { classes: klasses(*DESCRIPTION_BASE) }
        end
      end
    end
  end
end
