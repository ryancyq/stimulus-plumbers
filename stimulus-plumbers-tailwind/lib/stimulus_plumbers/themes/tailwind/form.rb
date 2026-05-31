# frozen_string_literal: true

module StimulusPlumbers
  module Themes
    module Tailwind
      module Form
        INPUT_BASE = %w[
          w-full rounded-(--sp-radius-md) border px-(--sp-space-3) py-(--sp-space-2) text-(length:--sp-text-sm)
          text-(--sp-color-fg) bg-(--sp-color-bg) focus:outline-none focus:ring-2 focus:ring-offset-0
          [.sp-form-input-group_&]:border-0 [.sp-form-input-group_&]:rounded-none
          [.sp-form-input-group_&]:bg-transparent [.sp-form-input-group_&]:shadow-none
          [.sp-form-input-group_&]:focus:ring-0
        ].freeze
        INPUT_ERROR   = %w[border-(--sp-color-error) focus:ring-(--sp-color-error)].freeze
        INPUT_DEFAULT = %w[border-(--sp-color-muted-fg) focus:ring-(--sp-focus-ring-color)].freeze

        GROUP_BASE    = %w[flex gap-(--sp-space-1) mb-(--sp-space-3)].freeze
        GROUP_INLINE  = %w[flex-row items-center].freeze

        LABEL         = %w[text-(length:--sp-text-sm) font-medium text-(--sp-color-fg)].freeze
        REQUIRED_MARK = %w[text-(--sp-color-error) ml-(--sp-space-0-5)].freeze
        DETAILS       = %w[text-(length:--sp-text-xs) text-(--sp-color-muted-fg)].freeze
        ERROR_TEXT    = %w[text-(length:--sp-text-xs) text-(--sp-color-error)].freeze
        CHECKBOX_VARIANTS = {
          default: %w[
            size-(--sp-control-size) rounded-(--sp-radius-sm)
            border border-(--sp-color-border) bg-(--sp-color-muted)
            focus:ring-2 focus:ring-(--sp-focus-ring-color) focus:outline-none
            disabled:opacity-50 disabled:cursor-not-allowed cursor-pointer
          ].freeze,
          button:  %w[
            size-(--sp-control-size) rounded-(--sp-radius-sm) shrink-0
            border border-(--sp-color-border) bg-(--sp-color-muted)
            focus:ring-2 focus:ring-(--sp-focus-ring-color) focus:outline-none
            disabled:opacity-50 disabled:cursor-not-allowed cursor-pointer
          ].freeze,
          card:    %w[
            size-(--sp-control-size) rounded-(--sp-radius-sm) shrink-0
            border border-(--sp-color-border) bg-(--sp-color-muted)
            focus:ring-2 focus:ring-(--sp-focus-ring-color) focus:outline-none
            disabled:opacity-50 disabled:cursor-not-allowed cursor-pointer
          ].freeze
        }.freeze

        RADIO_VARIANTS = {
          default: %w[
            size-(--sp-control-size) rounded-full
            border border-(--sp-color-border) bg-(--sp-color-muted)
            appearance-none cursor-pointer
            checked:border-(--sp-color-primary)
            focus:ring-2 focus:ring-(--sp-focus-ring-color) focus:outline-none
            disabled:opacity-50 disabled:cursor-not-allowed
          ].freeze,
          button:  %w[hidden peer].freeze,
          card:    %w[hidden peer].freeze
        }.freeze

        INPUT_GROUP_BASE   = %w[flex items-center overflow-hidden rounded-(--sp-radius-md) border].freeze
        INPUT_GROUP_BORDER = { error: "border-(--sp-color-error)", default: "border-(--sp-color-muted-fg)" }.freeze

        CHECKBOX_LABEL_VARIANTS = {
          default: %w[
            flex items-center gap-(--sp-space-2) cursor-pointer py-(--sp-space-0-5) select-none
            text-(length:--sp-text-sm) text-(--sp-color-fg)
          ].freeze,
          button:  %w[
            flex items-start gap-(--sp-space-3) flex-1 p-(--sp-space-4) cursor-pointer select-none
            text-(length:--sp-text-sm) text-(--sp-color-muted-fg)
            bg-(--sp-color-bg) border border-(--sp-color-border) rounded-(--sp-radius-md) shadow-(--sp-shadow-sm)
            hover:bg-(--sp-color-muted)
          ].freeze,
          card:    %w[
            flex justify-between items-start flex-1 p-(--sp-space-4) cursor-pointer select-none
            text-(length:--sp-text-sm) text-(--sp-color-muted-fg)
            bg-(--sp-color-bg) border border-(--sp-color-border) rounded-(--sp-radius-md) shadow-(--sp-shadow-sm)
            hover:bg-(--sp-color-muted)
          ].freeze
        }.freeze

        RADIO_LABEL_VARIANTS = {
          default: %w[
            flex items-center gap-(--sp-space-2) cursor-pointer py-(--sp-space-0-5) select-none
            text-(length:--sp-text-sm) text-(--sp-color-fg)
          ].freeze,
          button:  %w[
            inline-flex items-center justify-between flex-1 p-(--sp-space-4) cursor-pointer select-none
            text-(length:--sp-text-sm) text-(--sp-color-muted-fg)
            bg-(--sp-color-bg) border border-(--sp-color-border) rounded-(--sp-radius-md)
            hover:bg-(--sp-color-muted)
            peer-checked:border-(--sp-color-primary) peer-checked:bg-(--sp-color-primary)/10
            peer-checked:text-(--sp-color-fg) peer-checked:hover:bg-(--sp-color-primary)/15
          ].freeze,
          card:    %w[
            flex flex-col items-start flex-1 p-(--sp-space-4) cursor-pointer select-none
            text-(length:--sp-text-sm) text-(--sp-color-muted-fg)
            bg-(--sp-color-bg) border border-(--sp-color-border) rounded-(--sp-radius-md) shadow-(--sp-shadow-sm)
            hover:bg-(--sp-color-muted)
            peer-checked:border-(--sp-color-primary) peer-checked:bg-(--sp-color-primary)/10
            peer-checked:text-(--sp-color-fg) peer-checked:hover:bg-(--sp-color-primary)/15
          ].freeze
        }.freeze

        CHOICE_ITEMS_LAYOUT = {
          stacked: %w[flex flex-col gap-(--sp-space-1)].freeze,
          inline:  %w[flex flex-row flex-wrap gap-x-(--sp-space-4) gap-y-(--sp-space-1)].freeze
        }.freeze

        BUTTON_REVEAL = %w[
          self-stretch border-0 bg-transparent px-(--sp-space-3) cursor-pointer text-(--sp-color-muted-fg)
          hover:text-(--sp-color-fg) text-(length:--sp-text-sm)
        ].freeze
        BUTTON_CLEAR = %w[
          self-stretch border-0 bg-transparent px-(--sp-space-2) cursor-pointer text-(--sp-color-muted-fg)
          hover:text-(--sp-color-fg) text-(length:--sp-text-sm)
        ].freeze
        SUBMIT_LINK = %w[cursor-pointer text-(length:--sp-text-sm) font-medium text-(--sp-color-fg) hover:underline].freeze

        private

        def form_group_classes(layout: :stacked, **_rest)
          { classes: klasses(*GROUP_BASE, layout == :inline ? GROUP_INLINE : "flex-col") }
        end

        def form_label_classes(hidden: false, **)
          { classes: klasses(*LABEL, hidden ? "sr-only" : nil) }
        end

        def form_required_mark_classes
          { classes: klasses(*REQUIRED_MARK) }
        end

        def form_details_classes
          { classes: klasses(*DETAILS) }
        end

        def form_error_classes
          { classes: klasses(*ERROR_TEXT) }
        end

        def form_input_classes(error: false)
          { classes: klasses(*INPUT_BASE, *(error ? INPUT_ERROR : INPUT_DEFAULT)) }
        end

        def form_textarea_classes(error: false)
          form_input_classes(error: error)
        end

        def form_file_classes(error: false)
          form_input_classes(error: error)
        end

        def form_select_classes(error: false)
          form_input_classes(error: error)
        end

        def form_checkbox_classes(variant: :default, **)
          { classes: klasses(*CHECKBOX_VARIANTS.fetch(variant)) }
        end

        def form_radio_classes(variant: :default, **)
          { classes: klasses(*RADIO_VARIANTS.fetch(variant)) }
        end

        def input_group_classes(error: false)
          { classes: klasses(*INPUT_GROUP_BASE, INPUT_GROUP_BORDER[error ? :error : :default]) }
        end

        def form_combobox_classes(error: false)
          { classes: klasses(*INPUT_BASE, *(error ? INPUT_ERROR : INPUT_DEFAULT), "sp-form-combobox") }
        end

        def form_input_reveal_classes(**)
          { classes: "sp-form-input-group" }
        end

        def form_input_clearable_classes
          { classes: "sp-form-input-group" }
        end

        def form_checkbox_label_classes(variant: :default)
          { classes: klasses(*CHECKBOX_LABEL_VARIANTS.fetch(variant)) }
        end

        def form_radio_label_classes(variant: :default)
          { classes: klasses(*RADIO_LABEL_VARIANTS.fetch(variant)) }
        end

        def form_choice_items_classes(layout: :stacked)
          { classes: klasses(*CHOICE_ITEMS_LAYOUT.fetch(layout)) }
        end

        def form_button_reveal_classes
          { classes: klasses(*BUTTON_REVEAL) }
        end

        def form_button_clear_classes
          { classes: klasses(*BUTTON_CLEAR) }
        end

        def form_submit_classes(variant: :default)
          case variant
          when :button
            { classes: klasses(*Button::BASE, *Button::VARIANTS[:primary], *Button::SIZES[:md]) }
          else
            { classes: klasses(*SUBMIT_LINK) }
          end
        end
      end
    end
  end
end
