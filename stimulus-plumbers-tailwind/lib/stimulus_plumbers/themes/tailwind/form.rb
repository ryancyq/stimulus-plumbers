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

        FLOATING_INPUT_BASE = %w[
          w-full text-(length:--sp-text-sm) text-(--sp-color-fg) appearance-none
          focus:outline-none focus:ring-0
        ].freeze
        FLOATING_INPUT_TYPES = {
          floating_filled:   %w[
            rounded-t-(--sp-radius-md) px-(--sp-space-2-5) pb-(--sp-space-2-5) pt-(--sp-space-5)
            bg-(--sp-color-bg-muted) border-0 border-b-2
          ].freeze,
          floating_outlined: %w[
            px-(--sp-space-2-5) pb-(--sp-space-2-5) pt-(--sp-space-4)
            bg-transparent rounded-(--sp-radius-md) border
          ].freeze,
          floating_standard: %w[
            py-(--sp-space-2-5) px-0
            bg-transparent border-0 border-b-2
          ].freeze
        }.freeze
        FLOATING_INPUT_ERROR   = %w[border-(--sp-color-error)].freeze
        FLOATING_INPUT_DEFAULT = %w[border-(--sp-color-muted-fg) focus:border-(--sp-color-primary)].freeze

        FLOATING_GROUP_TYPES = {
          floating_filled:   %w[relative].freeze,
          floating_outlined: %w[relative].freeze,
          floating_standard: %w[relative z-0].freeze
        }.freeze

        FLOATING_LABEL_BASE = %w[
          absolute text-(length:--sp-text-sm) text-(--sp-color-muted-fg)
          duration-300 transform origin-[0]
        ].freeze
        FLOATING_LABEL_FOCUS   = %w[peer-focus:text-(--sp-color-primary)].freeze
        FLOATING_LABEL_ERROR   = %w[text-(--sp-color-error)].freeze
        FLOATING_LABEL_TYPES = {
          floating_filled:   %w[
            -translate-y-(--sp-space-4) scale-75 top-(--sp-space-4) z-10 start-(--sp-space-2-5)
            peer-placeholder-shown:scale-100 peer-placeholder-shown:translate-y-0
            peer-focus:scale-75 peer-focus:-translate-y-(--sp-space-4)
            rtl:peer-focus:translate-x-1/4 rtl:peer-focus:left-auto
          ].freeze,
          floating_outlined: %w[
            -translate-y-(--sp-space-4) scale-75 top-(--sp-space-2) z-10 start-1
            bg-(--sp-color-bg) px-(--sp-space-2) peer-focus:px-(--sp-space-2)
            peer-placeholder-shown:scale-100 peer-placeholder-shown:-translate-y-1/2 peer-placeholder-shown:top-1/2
            peer-focus:top-(--sp-space-2) peer-focus:scale-75 peer-focus:-translate-y-(--sp-space-4)
            rtl:peer-focus:translate-x-1/4 rtl:peer-focus:left-auto
          ].freeze,
          floating_standard: %w[
            -translate-y-(--sp-space-6) scale-75 top-(--sp-space-3) -z-10 start-0
            peer-focus:start-0
            peer-placeholder-shown:scale-100 peer-placeholder-shown:translate-y-0
            peer-focus:scale-75 peer-focus:-translate-y-(--sp-space-6)
            rtl:peer-focus:translate-x-1/4 rtl:peer-focus:left-auto
          ].freeze
        }.freeze

        GROUP_BASE    = %w[flex gap-(--sp-space-1) mb-(--sp-space-3)].freeze
        GROUP_INLINE  = %w[flex-row items-center].freeze

        LABEL         = %w[text-(length:--sp-text-sm) font-medium text-(--sp-color-fg)].freeze
        REQUIRED_MARK = %w[text-(--sp-color-error) ml-(--sp-space-0-5)].freeze
        DETAILS       = %w[text-(length:--sp-text-xs) text-(--sp-color-muted-fg)].freeze
        ERROR_TEXT    = %w[text-(length:--sp-text-xs) text-(--sp-color-error)].freeze
        CHECKBOX_TYPES = {
          default: %w[
            size-(--sp-control-size) rounded-(--sp-radius-sm) shrink-0
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
            checked:border-(--card-ring)
            focus:ring-2 focus:ring-(--card-ring) focus:outline-none
            disabled:opacity-50 disabled:cursor-not-allowed cursor-pointer
          ].freeze
        }.freeze

        RADIO_TYPES = {
          default: %w[
            size-(--sp-control-size) rounded-full shrink-0
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

        CARD_VARIANTS = {
          default:     %w[[--card-ring:var(--sp-color-primary)]].freeze,
          success:     %w[[--card-ring:var(--sp-color-success)]].freeze,
          destructive: %w[[--card-ring:var(--sp-color-destructive)]].freeze,
          warning:     %w[[--card-ring:var(--sp-color-warning)]].freeze,
          info:        %w[[--card-ring:var(--sp-color-info)]].freeze
        }.freeze

        CHECKBOX_LABEL_TYPES = {
          default: %w[
            flex items-center gap-(--sp-space-2) cursor-pointer py-(--sp-space-0-5) select-none
            text-(length:--sp-text-sm) text-(--sp-color-fg)
          ].freeze,
          button:  %w[
            flex items-start gap-(--sp-space-3) flex-1 p-(--sp-space-4) cursor-pointer select-none
            text-(length:--sp-text-sm) text-(--sp-color-muted-fg)
            bg-(--sp-color-bg) border border-(--sp-color-border) rounded-(--sp-radius-md) shadow-(--sp-shadow-xs)
            hover:bg-(--sp-color-muted)
          ].freeze,
          card:    %w[
            flex justify-between items-start flex-1 p-(--sp-space-4) cursor-pointer select-none
            text-(length:--sp-text-sm) text-(--sp-color-muted-fg)
            bg-(--sp-color-bg) border border-(--sp-color-border) rounded-(--sp-radius-md) shadow-(--sp-shadow-xs)
            hover:bg-(--sp-color-muted) hover:border-(--sp-color-border-strong) hover:text-(--sp-color-fg)
            has-[:checked]:border-(--card-ring) has-[:checked]:bg-(--card-ring)/10
            has-[:checked]:text-(--sp-color-fg) has-[:checked]:hover:bg-(--card-ring)/15
          ].freeze
        }.freeze

        RADIO_LABEL_TYPES = {
          default: %w[
            flex items-center gap-(--sp-space-2) cursor-pointer py-(--sp-space-0-5) select-none
            text-(length:--sp-text-sm) text-(--sp-color-fg)
          ].freeze,
          button:  %w[
            inline-flex items-center justify-between flex-1 p-(--sp-space-4) cursor-pointer select-none
            text-(length:--sp-text-sm) text-(--sp-color-muted-fg)
            bg-(--sp-color-bg) border border-(--sp-color-border) rounded-(--sp-radius-md)
            hover:bg-(--sp-color-muted)
            peer-checked:border-(--card-ring) peer-checked:bg-(--card-ring)/10
            peer-checked:text-(--sp-color-fg) peer-checked:hover:bg-(--card-ring)/15
          ].freeze,
          card:    %w[
            flex items-start flex-1 p-(--sp-space-4) cursor-pointer select-none
            text-(length:--sp-text-sm) text-(--sp-color-muted-fg)
            bg-(--sp-color-bg) border border-(--sp-color-border) rounded-(--sp-radius-md) shadow-(--sp-shadow-xs)
            hover:bg-(--sp-color-muted) hover:border-(--sp-color-border-strong) hover:text-(--sp-color-fg)
            peer-checked:border-(--card-ring) peer-checked:bg-(--card-ring)/10
            peer-checked:text-(--sp-color-fg) peer-checked:hover:bg-(--card-ring)/15
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

        def form_floating_input_classes(type: nil, error: false)
          {
            classes: klasses(
              *FLOATING_INPUT_BASE,
              *FLOATING_INPUT_TYPES.fetch(type, []),
              *(error ? FLOATING_INPUT_ERROR : FLOATING_INPUT_DEFAULT)
            )
          }
        end

        def form_floating_group_classes(type: nil)
          { classes: klasses(*FLOATING_GROUP_TYPES.fetch(type, [])) }
        end

        def form_floating_label_classes(type: nil, error: false)
          color = error ? FLOATING_LABEL_ERROR : FLOATING_LABEL_FOCUS
          { classes: klasses(*FLOATING_LABEL_BASE, *FLOATING_LABEL_TYPES.fetch(type, []), *color) }
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

        def form_checkbox_classes(type: :default, variant: :default, **)
          card_color = type == :card ? CARD_VARIANTS.fetch(variant, CARD_VARIANTS[:default]) : []
          { classes: klasses(*CHECKBOX_TYPES.fetch(type), *card_color) }
        end

        def form_radio_classes(type: :default, variant: :default, **)
          { classes: klasses(*RADIO_TYPES.fetch(type)) }
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

        def form_checkbox_label_classes(type: :default, variant: :default)
          card_color = type == :card ? CARD_VARIANTS.fetch(variant, CARD_VARIANTS[:default]) : []
          { classes: klasses(*CHECKBOX_LABEL_TYPES.fetch(type), *card_color) }
        end

        def form_radio_label_classes(type: :default, variant: :default)
          card_color = %i[button card].include?(type) ? CARD_VARIANTS.fetch(variant, CARD_VARIANTS[:default]) : []
          { classes: klasses(*RADIO_LABEL_TYPES.fetch(type), *card_color) }
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

        def form_submit_classes(type: :default)
          case type
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
