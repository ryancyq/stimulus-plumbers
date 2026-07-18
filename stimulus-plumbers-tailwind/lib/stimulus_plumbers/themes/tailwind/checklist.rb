# frozen_string_literal: true

module StimulusPlumbers
  module Themes
    module Tailwind
      module Checklist
        WRAPPER_BASE = %w[flex flex-col gap-(--sp-space-1)].freeze

        ITEM_BASE = [
          *Control::BASE,
          "group/checklist-item flex items-center gap-(--sp-space-2) w-full text-start",
          "px-(--sp-space-2) py-(--sp-space-1)",
          "rounded-(--sp-radius-sm) text-(length:--sp-text-sm)",
          "cursor-pointer select-none text-(--sp-color-fg)",
          "hover:bg-(--sp-color-muted)",
          "has-disabled:cursor-default has-disabled:hover:bg-transparent"
        ].freeze

        INPUT_BASE = [
          *Control::ACCENT,
          "size-(--sp-control-size) rounded-(--sp-radius-sm) shrink-0",
          "border border-(--sp-color-border) bg-(--sp-color-muted)",
          "focus:ring-(length:--sp-focus-ring-width) focus:ring-(--sp-focus-ring-color) focus:outline-none",
          "disabled:opacity-50 disabled:cursor-not-allowed cursor-pointer"
        ].freeze

        CONTENT_BASE = %w[flex flex-col flex-1 min-w-0].freeze

        TITLE_BASE = %w[
          text-(length:--sp-text-sm) font-medium text-(--sp-color-fg)
          group-has-checked/checklist-item:line-through
          group-has-checked/checklist-item:text-(--sp-color-muted-fg)
        ].freeze

        DESCRIPTION_BASE = %w[text-(length:--sp-text-xs) text-(--sp-color-muted-fg)].freeze

        private

        def checklist_classes
          { classes: klasses(*WRAPPER_BASE) }
        end

        def checklist_item_classes
          { classes: klasses(*ITEM_BASE) }
        end

        def checklist_item_input_classes
          { classes: klasses(*INPUT_BASE) }
        end

        def checklist_item_content_classes
          { classes: klasses(*CONTENT_BASE) }
        end

        def checklist_item_title_classes
          { classes: klasses(*TITLE_BASE) }
        end

        def checklist_item_description_classes
          { classes: klasses(*DESCRIPTION_BASE) }
        end
      end
    end
  end
end
