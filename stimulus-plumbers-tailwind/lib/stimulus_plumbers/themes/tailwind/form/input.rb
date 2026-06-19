# frozen_string_literal: true

module StimulusPlumbers
  module Themes
    module Tailwind
      module Form
        module Input
          FLOATING_INPUT_BASE = %w[
            peer w-full text-(length:--sp-text-sm) text-(--sp-color-fg) appearance-none
            focus:outline-none focus:ring-0
            focus-visible:outline-none focus-visible:ring-0
          ].freeze
          FLOATING_INPUT_TYPES = {
            filled:   %w[
              rounded-t-(--sp-radius-md) px-(--sp-space-2-5) pb-(--sp-space-2-5) pt-(--sp-space-5)
              bg-(--sp-color-bg-muted) border-0 border-b-2
            ].freeze,
            outlined: %w[
              px-(--sp-space-2-5) pb-(--sp-space-2-5) pt-(--sp-space-4)
              bg-transparent rounded-(--sp-radius-md) border
            ].freeze,
            standard: %w[
              py-(--sp-space-2-5) px-0
              bg-transparent border-0 border-b-2
            ].freeze
          }.freeze
          FLOATING_INPUT_ERROR   = %w[border-(--sp-color-error)].freeze
          FLOATING_INPUT_DEFAULT = %w[border-(--sp-color-muted-fg) focus:border-(--sp-color-primary)].freeze

          INPUT_BASE = %w[
            w-full rounded-(--sp-radius-md) border px-(--sp-space-3) py-(--sp-space-2)
            text-(length:--sp-text-sm) text-(--sp-color-fg) bg-(--sp-color-bg)
            focus:outline-none focus:ring-(length:--sp-focus-ring-width) focus:ring-offset-0
          ].freeze
          INPUT_ERROR   = %w[border-(--sp-color-error) focus:ring-(--sp-color-error)].freeze
          INPUT_DEFAULT = %w[border-(--sp-color-muted-fg) focus:ring-(--sp-focus-ring-color)].freeze

          CHECKBOX_TYPES = {
            default: %w[
              size-(--sp-control-size) rounded-(--sp-radius-sm) shrink-0
              border border-(--sp-color-border) bg-(--sp-color-muted)
              focus:ring-(length:--sp-focus-ring-width) focus:ring-(--sp-focus-ring-color) focus:outline-none
              disabled:opacity-50 disabled:cursor-not-allowed cursor-pointer
            ].freeze,
            button:  %w[
              size-(--sp-control-size) rounded-(--sp-radius-sm) shrink-0
              border border-(--sp-color-border) bg-(--sp-color-muted)
              focus:ring-(length:--sp-focus-ring-width) focus:ring-(--sp-focus-ring-color) focus:outline-none
              disabled:opacity-50 disabled:cursor-not-allowed cursor-pointer
            ].freeze,
            card:    %w[
              size-(--sp-control-size) rounded-(--sp-radius-sm) shrink-0
              border border-(--sp-color-border) bg-(--sp-color-muted)
              checked:border-(--card-ring)
              focus:ring-(length:--sp-focus-ring-width) focus:ring-(--card-ring) focus:outline-none
              disabled:opacity-50 disabled:cursor-not-allowed cursor-pointer
            ].freeze
          }.freeze

          RADIO_TYPES = {
            default: %w[
              size-(--sp-control-size) rounded-full shrink-0
              [accent-color:var(--sp-color-primary)] cursor-pointer
              focus:ring-(length:--sp-focus-ring-width) focus:ring-(--sp-focus-ring-color) focus:outline-none
              disabled:opacity-50 disabled:cursor-not-allowed
            ].freeze,
            button:  %w[hidden].freeze,
            card:    %w[hidden].freeze
          }.freeze

          INPUT_GROUP_BASE   = %w[flex items-center overflow-hidden rounded-(--sp-radius-md) border].freeze
          INPUT_GROUP_BORDER = { error: "border-(--sp-color-error)", default: "border-(--sp-color-muted-fg)" }.freeze

          COMBOBOX_INPUT = %w[
            [&>input:not([type=hidden])]:border-0
            [&>input:not([type=hidden])]:rounded-none
            [&>input:not([type=hidden])]:px-0
            [&>input:not([type=hidden])]:py-0
            [&>input:not([type=hidden])]:bg-transparent
            [&>input:not([type=hidden])]:shadow-none
            [&>input:not([type=hidden])]:focus:ring-0
          ].freeze
          COMBOBOX_TRIGGER_GROUP = %w[
            [&>div:first-child]:border-0
            [&>div:first-child]:rounded-none
            [&>div:first-child]:px-0
            [&>div:first-child]:py-0
            [&>div:first-child]:focus-within:ring-0
          ].freeze

          BUTTON_REVEAL = %w[
            self-stretch border-0 bg-transparent px-(--sp-space-3) cursor-pointer text-(--sp-color-muted-fg)
            hover:text-(--sp-color-fg) text-(length:--sp-text-sm)
          ].freeze
          BUTTON_CLEAR = %w[
            self-stretch border-0 bg-transparent px-(--sp-space-2) cursor-pointer text-(--sp-color-muted-fg)
            rounded-(--sp-radius-sm) hover:bg-(--sp-color-muted) hover:text-(--sp-color-fg) text-(length:--sp-text-sm)
          ].freeze

          private

          def form_field_input_classes(floating: nil, error: false)
            if floating
              { classes: klasses(
                *FLOATING_INPUT_BASE,
                *FLOATING_INPUT_TYPES.fetch(floating, []),
                *(error ? FLOATING_INPUT_ERROR : FLOATING_INPUT_DEFAULT)
              )
}
            else
              { classes: klasses(*INPUT_BASE, *(error ? INPUT_ERROR : INPUT_DEFAULT)) }
            end
          end

          def form_field_input_textarea_classes(floating: nil, error: false)
            form_field_input_classes(floating: floating, error: error)
          end

          def form_field_input_file_classes(floating: nil, error: false)
            form_field_input_classes(floating: floating, error: error)
          end

          def form_field_input_select_classes(floating: nil, error: false)
            form_field_input_classes(floating: floating, error: error)
          end

          def form_field_input_checkbox_classes(type: :default, variant: :default, **)
            card_color = type == :card ? Card::VARIANTS.fetch(variant, Card::VARIANTS[:tertiary]) : []
            { classes: klasses(*CHECKBOX_TYPES.fetch(type), *card_color) }
          end

          def form_field_input_radio_classes(type: :default, variant: :default, **)
            card_color = %i[button card].include?(type) ? Card::VARIANTS.fetch(variant, Card::VARIANTS[:tertiary]) : []
            { classes: klasses(*RADIO_TYPES.fetch(type), *card_color) }
          end

          def input_group_classes(error: false)
            { classes: klasses(*INPUT_GROUP_BASE, INPUT_GROUP_BORDER[error ? :error : :default]) }
          end

          def form_field_input_combobox_classes(floating: nil, error: false)
            if floating
              form_field_input_combobox_floating_classes(floating, error)
            else
              {
                classes: klasses(
                  *INPUT_BASE,
                  *(error ? INPUT_ERROR : INPUT_DEFAULT),
                  *COMBOBOX_INPUT,
                  *COMBOBOX_TRIGGER_GROUP
                )
              }
            end
          end

          def form_field_input_combobox_floating_classes(floating: :standard, error: false)
            {
              classes: klasses(
                *FLOATING_INPUT_BASE,
                *FLOATING_INPUT_TYPES.fetch(floating, []),
                *(error ? FLOATING_INPUT_ERROR : FLOATING_INPUT_DEFAULT),
                *COMBOBOX_INPUT,
                *COMBOBOX_TRIGGER_GROUP
              )
            }
          end

          def form_field_input_reveal_classes(**)
            {
              classes: klasses(
                "[&>input]:border-0",
                "[&>input]:rounded-none",
                "[&>input]:bg-transparent",
                "[&>input]:shadow-none",
                "[&>input]:focus:ring-0"
              )
            }
          end

          def form_field_input_clearable_classes
            {
              classes: klasses(
                "[&>input]:border-0",
                "[&>input]:rounded-none",
                "[&>input]:bg-transparent",
                "[&>input]:shadow-none",
                "[&>input]:focus:ring-0"
              )
            }
          end

          def form_field_input_button_reveal_classes
            { classes: klasses(*BUTTON_REVEAL) }
          end

          def form_field_input_button_clear_classes
            { classes: klasses(*BUTTON_CLEAR) }
          end
        end
      end
    end
  end
end
