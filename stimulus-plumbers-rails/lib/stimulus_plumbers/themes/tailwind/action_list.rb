# frozen_string_literal: true

module StimulusPlumbers
  module Themes
    module Tailwind
      module ActionList
        LIST_ITEM_ACTIVE = %w[bg-[--sp-color-primary]/10 text-[--sp-color-primary]].freeze
        LIST_ITEM_BASE   = %w[
          flex items-center gap-[--sp-space-2] w-full
          px-[--sp-space-2] py-[--sp-space-1]
          rounded-[--sp-radius-sm] text-[--sp-text-sm]
          cursor-pointer select-none outline-none
          hover:bg-[--sp-color-muted] focus:bg-[--sp-color-muted] focus:text-[--sp-color-fg]
        ].freeze

        private

        def action_list_classes
          { classes: klasses("py-[--sp-space-1]") }
        end

        def action_list_item_classes(active: false)
          {
            classes: klasses(
              *LIST_ITEM_BASE,
              *(active ? LIST_ITEM_ACTIVE : [])
            )
          }
        end
      end
    end
  end
end
