# frozen_string_literal: true

module StimulusPlumbers
  module Themes
    module Tailwind
      module Combobox
        # ── Container / popover ───────────────────────────────────────────────
        # The panel anchors to its own field group.
        CONTAINER = %w[relative [anchor-scope:--sp-field]].freeze
        POPOVER   = %w[[&[popover]]:[position-anchor:--sp-field] [min-inline-size:anchor-size(inline)]].freeze

        # ── Trigger ───────────────────────────────────────────────────────────
        TRIGGER = %w[
          w-full flex-1 min-w-(--sp-combobox-min-size)
          rounded-(--sp-radius-md) border border-(--sp-color-muted-fg) hover:border-(--sp-color-fg)
          px-(--sp-space-3) py-(--sp-space-2)
          min-h-[1lh] text-start text-(length:--sp-text-sm) text-(--sp-color-fg) bg-(--sp-color-bg)
          focus:outline-none focus:ring-2 focus:ring-(--sp-focus-ring-color)
        ].freeze

        TRIGGER_GROUP = %w[
          flex items-center gap-(--sp-space-2) overflow-hidden [anchor-name:--sp-field]
          rounded-(--sp-radius-md) border border-(--sp-color-muted-fg) hover:border-(--sp-color-fg) bg-(--sp-color-bg)
          px-(--sp-space-3) py-(--sp-space-2)
          focus-within:outline-none focus-within:ring-2 focus-within:ring-(--sp-focus-ring-color)
          [&>[role=combobox]]:border-0 [&>[role=combobox]]:rounded-none
          [&>[role=combobox]]:px-0 [&>[role=combobox]]:py-0
          [&>[role=combobox]]:bg-transparent [&>[role=combobox]]:shadow-none
          [&>[role=combobox]]:focus:ring-0
        ].freeze

        # ── Listbox / options ─────────────────────────────────────────────────
        LISTBOX = %w[
          py-(--sp-space-1) overflow-y-auto max-h-60 min-h-(--sp-space-6)
          not-has-[[role=option]:not([hidden])]:hidden
        ].freeze

        OPTION = %w[
          flex flex-wrap items-center gap-x-(--sp-space-2) w-full
          px-(--sp-space-2) py-(--sp-space-1)
          rounded-(--sp-radius-sm) text-(length:--sp-text-sm)
          cursor-pointer select-none outline-none
          hover:bg-(--sp-color-muted) focus:bg-(--sp-color-muted)
        ].freeze

        # The active option has an outline as well as a tint.
        OPTION_SELECTED = %w[
          aria-selected:bg-(--sp-color-primary)/10 aria-selected:text-(--sp-color-primary)
          aria-selected:outline-solid aria-selected:outline-2 aria-selected:-outline-offset-2
          aria-selected:outline-(--sp-color-primary)
        ].freeze

        OPTION_DISABLED = %w[
          aria-disabled:opacity-50 aria-disabled:cursor-not-allowed aria-disabled:pointer-events-none
        ].freeze

        OPTION_DESCRIPTION = %w[basis-full text-(length:--sp-text-xs) text-(--sp-color-muted-fg)].freeze

        OPTION_GROUP = %w[py-(--sp-space-1)].freeze

        OPTION_GROUP_LABEL = %w[
          px-(--sp-space-2) py-(--sp-space-1)
          text-(length:--sp-text-xs) font-semibold text-(--sp-color-muted-fg)
        ].freeze

        # ── Status ────────────────────────────────────────────────────────────
        STATUS = %w[
          flex empty:hidden items-center justify-center
          px-(--sp-space-2) py-(--sp-space-2) text-(length:--sp-text-sm) text-(--sp-color-muted-fg)
        ].freeze

        # ── Time ──────────────────────────────────────────────────────────────
        TIME             = %w[flex gap-(--sp-space-2) overflow-hidden].freeze
        TIME_DRUM        = %w[
          rounded-(--sp-radius-sm) outline-none
          focus-visible:ring-2 focus-visible:ring-inset focus-visible:ring-(--sp-focus-ring-color)
        ].freeze
        TIME_DRUM_UNIT     = %w[flex-1 min-w-0].freeze
        TIME_DRUM_MERIDIEM = %w[shrink-0].freeze

        private

        def combobox_classes
          { classes: klasses(*CONTAINER) }
        end

        def combobox_dropdown_popover_classes
          { classes: klasses(*POPOVER) }
        end

        def combobox_typeahead_popover_classes
          { classes: klasses(*POPOVER) }
        end

        def combobox_date_popover_classes
          { classes: klasses(*POPOVER) }
        end

        def combobox_time_popover_classes
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

        def combobox_option_classes
          { classes: klasses(*OPTION, *OPTION_SELECTED, *OPTION_DISABLED) }
        end

        def combobox_option_description_classes
          { classes: klasses(*OPTION_DESCRIPTION) }
        end

        def combobox_option_group_classes
          { classes: klasses(*OPTION_GROUP) }
        end

        def combobox_option_group_label_classes
          { classes: klasses(*OPTION_GROUP_LABEL) }
        end

        def combobox_status_classes
          { classes: klasses(*STATUS) }
        end

        def combobox_time_classes
          { classes: klasses(*TIME) }
        end

        def combobox_time_drum_classes(type: :unit)
          { classes: klasses(*TIME_DRUM, *(type == :meridiem ? TIME_DRUM_MERIDIEM : TIME_DRUM_UNIT)) }
        end
      end
    end
  end
end
