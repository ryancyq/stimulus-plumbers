# frozen_string_literal: true

module StimulusPlumbers
  module Themes
    module Tailwind
      module Combobox
        LISTBOX = %w[
          py-[--sp-space-1] overflow-y-auto max-h-60
        ].freeze

        OPTION_BASE = %w[
          flex items-center gap-[--sp-space-2] w-full
          px-[--sp-space-2] py-[--sp-space-1]
          rounded-[--sp-radius-sm] text-[--sp-text-sm]
          cursor-pointer select-none outline-none
          hover:bg-[--sp-color-muted] focus:bg-[--sp-color-muted]
        ].freeze

        OPTION_SELECTED = %w[
          bg-[--sp-color-primary]/10 text-[--sp-color-primary]
        ].freeze

        OPTION_DISABLED = %w[
          opacity-50 cursor-not-allowed pointer-events-none
        ].freeze

        OPTION_GROUP = %w[py-[--sp-space-1]].freeze

        AUTOCOMPLETE_LOADING = %w[
          flex items-center justify-center
          py-[--sp-space-2] text-[--sp-text-sm] text-[--sp-color-muted-fg]
        ].freeze

        AUTOCOMPLETE_EMPTY = %w[
          flex items-center justify-center
          py-[--sp-space-2] text-[--sp-text-sm] text-[--sp-color-muted-fg]
        ].freeze

        TIME = %w[flex gap-[--sp-space-2] overflow-hidden].freeze

        private

        def combobox_listbox_classes
          { classes: klasses(*LISTBOX) }
        end

        def combobox_option_classes(selected: false, disabled: false)
          {
            classes: klasses(
              *OPTION_BASE,
              *(selected ? OPTION_SELECTED : []),
              *(disabled ? OPTION_DISABLED : [])
            )
          }
        end

        def combobox_option_group_classes
          { classes: klasses(*OPTION_GROUP) }
        end

        def combobox_autocomplete_loading_classes
          { classes: klasses(*AUTOCOMPLETE_LOADING) }
        end

        def combobox_autocomplete_empty_classes
          { classes: klasses(*AUTOCOMPLETE_EMPTY) }
        end

        def combobox_time_classes
          { classes: klasses(*TIME) }
        end
      end
    end
  end
end
