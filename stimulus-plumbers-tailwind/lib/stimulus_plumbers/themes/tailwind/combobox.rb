# frozen_string_literal: true

module StimulusPlumbers
  module Themes
    module Tailwind
      module Combobox
        TRIGGER = %w[
          w-full rounded-(--sp-radius-md) border border-(--sp-color-muted-fg)
          px-(--sp-space-3) py-(--sp-space-2)
          text-(length:--sp-text-sm) text-(--sp-color-fg) bg-(--sp-color-bg)
          focus:outline-none focus:ring-2 focus:ring-(--sp-focus-ring-color)
        ].freeze

        TRIGGER_GROUP = %w[
          flex items-center gap-(--sp-space-2) overflow-hidden
          rounded-(--sp-radius-md) border border-(--sp-color-muted-fg) bg-(--sp-color-bg)
          px-(--sp-space-3) py-(--sp-space-2)
          focus-within:outline-none focus-within:ring-2 focus-within:ring-(--sp-focus-ring-color)
          [&>input]:border-0 [&>input]:rounded-none
          [&>input]:px-0 [&>input]:py-0
          [&>input]:bg-transparent [&>input]:shadow-none
          [&>input]:focus:ring-0
        ].freeze

        LISTBOX = %w[
          py-(--sp-space-1) overflow-y-auto max-h-60
        ].freeze

        OPTION_BASE = %w[
          flex items-center gap-(--sp-space-2) w-full
          px-(--sp-space-2) py-(--sp-space-1)
          rounded-(--sp-radius-sm) text-(length:--sp-text-sm)
          cursor-pointer select-none outline-none
          hover:bg-(--sp-color-muted) focus:bg-(--sp-color-muted)
        ].freeze

        OPTION_SELECTED = %w[
          bg-(--sp-color-primary)/10 text-(--sp-color-primary)
        ].freeze

        OPTION_DISABLED = %w[
          opacity-50 cursor-not-allowed pointer-events-none
        ].freeze

        OPTION_GROUP = %w[py-(--sp-space-1)].freeze

        TYPEAHEAD_LOADING = %w[
          flex items-center justify-center
          py-(--sp-space-2) text-(length:--sp-text-sm) text-(--sp-color-muted-fg)
        ].freeze

        TYPEAHEAD_EMPTY = %w[
          flex items-center justify-center
          py-(--sp-space-2) text-(length:--sp-text-sm) text-(--sp-color-muted-fg)
        ].freeze

        TIME             = %w[flex gap-(--sp-space-2) overflow-hidden].freeze
        TIME_DRUM_UNIT   = %w[flex-1 min-w-0].freeze
        TIME_DRUM_PERIOD = %w[shrink-0].freeze

        DATE_NAV = %w[flex items-center justify-between gap-(--sp-space-1) mb-(--sp-space-2)].freeze

        DATE_NAV_BTN   = %w[size-(--sp-control-size)].freeze
        DATE_NAV_TITLE = %w[flex-1 text-center h-(--sp-control-size)].freeze

        CONTAINER = %w[relative].freeze
        POPOVER   = %w[absolute top-full left-0 min-w-full].freeze

        private

        def combobox_classes
          { classes: klasses(*CONTAINER) }
        end

        def combobox_popover_classes
          { classes: klasses(*POPOVER) }
        end

        def combobox_trigger_classes
          { classes: klasses(*TRIGGER) }
        end

        def combobox_trigger_group_classes
          { classes: klasses(*TRIGGER_GROUP) }
        end

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

        def combobox_typeahead_loading_classes
          { classes: klasses(*TYPEAHEAD_LOADING) }
        end

        def combobox_typeahead_loading_icon_classes
          { classes: klasses("size-(--sp-icon-size)", "animate-spin") }
        end

        def combobox_typeahead_empty_classes
          { classes: klasses(*TYPEAHEAD_EMPTY) }
        end

        def combobox_time_classes
          { classes: klasses(*TIME) }
        end

        def combobox_time_drum_classes(type: :unit)
          { classes: klasses(*(type == :period ? TIME_DRUM_PERIOD : TIME_DRUM_UNIT)) }
        end

        def combobox_date_navigation_classes
          { classes: klasses(*DATE_NAV) }
        end

        def combobox_date_navigation_navigator_classes
          { classes: klasses(*DATE_NAV_BTN) }
        end

        def combobox_date_navigation_title_classes
          { classes: klasses(*DATE_NAV_TITLE) }
        end
      end
    end
  end
end
