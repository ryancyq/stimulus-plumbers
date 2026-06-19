# frozen_string_literal: true

module StimulusPlumbers
  module Themes
    module Tailwind
      module Form
        module Field
          LABEL         = %w[text-(length:--sp-text-sm) font-medium text-(--sp-color-fg)].freeze
          REQUIRED_MARK = %w[text-(--sp-color-error) ml-(--sp-space-0-5)].freeze
          HINT          = %w[text-(length:--sp-text-xs) text-(--sp-color-muted-fg)].freeze
          ERROR_TEXT    = %w[text-(length:--sp-text-xs) text-(--sp-color-error)].freeze

          FLOATING_GROUP_TYPES = {
            filled:   %w[relative].freeze,
            outlined: %w[relative].freeze,
            standard: %w[relative z-0].freeze
          }.freeze

          FLOATING_LABEL_BASE = %w[
            absolute text-(length:--sp-text-sm) text-(--sp-color-muted-fg)
            duration-300 transform origin-[0]
          ].freeze
          FLOATING_LABEL_FOCUS   = %w[peer-focus-within:text-(--sp-color-primary)].freeze
          FLOATING_LABEL_ERROR   = %w[text-(--sp-color-error)].freeze
          FLOATING_LABEL_TYPES = {
            filled:   %w[
              -translate-y-(--sp-space-4) scale-75 top-(--sp-space-4) z-10 start-(--sp-space-2-5)
              peer-placeholder-shown:scale-100
              peer-placeholder-shown:translate-y-0
              peer-has-[input:not(:focus):placeholder-shown]:scale-100
              peer-has-[input:not(:focus):placeholder-shown]:translate-y-0
              peer-focus-within:scale-75
              peer-focus-within:-translate-y-(--sp-space-4)
              rtl:peer-focus-within:translate-x-1/4 rtl:peer-focus-within:left-auto
            ].freeze,
            outlined: %w[
              -translate-y-(--sp-space-4) scale-75 top-(--sp-space-2) z-10 start-1
              bg-(--sp-color-bg) px-(--sp-space-2) peer-focus-within:px-(--sp-space-2)
              peer-placeholder-shown:scale-100
              peer-placeholder-shown:-translate-y-1/2
              peer-placeholder-shown:top-1/2
              peer-has-[input:not(:focus):placeholder-shown]:scale-100
              peer-has-[input:not(:focus):placeholder-shown]:-translate-y-1/2
              peer-has-[input:not(:focus):placeholder-shown]:top-1/2
              peer-focus-within:top-(--sp-space-2) peer-focus-within:scale-75
              peer-focus-within:-translate-y-(--sp-space-4)
              rtl:peer-focus-within:translate-x-1/4 rtl:peer-focus-within:left-auto
            ].freeze,
            standard: %w[
              -translate-y-(--sp-space-6) scale-75 top-(--sp-space-3) -z-10 start-0
              peer-focus-within:start-0
              peer-placeholder-shown:scale-100
              peer-placeholder-shown:translate-y-0
              peer-has-[input:not(:focus):placeholder-shown]:scale-100
              peer-has-[input:not(:focus):placeholder-shown]:translate-y-0
              peer-focus-within:scale-75
              peer-focus-within:-translate-y-(--sp-space-6)
              rtl:peer-focus-within:translate-x-1/4 rtl:peer-focus-within:left-auto
            ].freeze
          }.freeze

          CHECKBOX_LABEL_TYPES = {
            default: %w[
              flex items-center gap-(--sp-space-2) cursor-pointer py-(--sp-space-0-5) select-none
              text-(length:--sp-text-sm) text-(--sp-color-fg)
            ].freeze,
            button:  %w[
              flex items-center gap-(--sp-space-3) flex-1 p-(--sp-space-4) cursor-pointer select-none
              text-(length:--sp-text-sm) text-(--sp-color-muted-fg)
              bg-(--sp-color-bg) border border-(--sp-color-border) rounded-(--sp-radius-md) shadow-(--sp-shadow-xs)
              hover:bg-(--sp-color-muted)
            ].freeze,
            card:    %w[
              flex justify-between items-center gap-(--sp-space-3) flex-1 p-(--sp-space-4) cursor-pointer select-none
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

          private

          def form_field_input_group_classes(floating: nil)
            { classes: klasses(*FLOATING_GROUP_TYPES.fetch(floating, [])) }
          end

          def form_field_label_classes(floating: nil, hidden: false, error: false, **)
            if floating
              color = error ? FLOATING_LABEL_ERROR : FLOATING_LABEL_FOCUS
              { classes: klasses(*FLOATING_LABEL_BASE, *FLOATING_LABEL_TYPES.fetch(floating, []), *color) }
            else
              { classes: klasses(*LABEL, hidden ? "sr-only" : nil) }
            end
          end

          def form_field_required_mark_classes
            { classes: klasses(*REQUIRED_MARK) }
          end

          def form_field_hint_classes
            { classes: klasses(*HINT) }
          end

          def form_field_error_classes
            { classes: klasses(*ERROR_TEXT) }
          end

          def form_field_choice_items_classes(layout: :stacked)
            { classes: klasses(*CHOICE_ITEMS_LAYOUT.fetch(layout)) }
          end

          def form_field_checkbox_label_classes(type: :default, variant: :default)
            card_color = type == :card ? Card::VARIANTS.fetch(variant, Card::VARIANTS[:tertiary]) : []
            { classes: klasses(*CHECKBOX_LABEL_TYPES.fetch(type), *card_color) }
          end

          def form_field_radio_label_classes(type: :default, variant: :default)
            card_color = %i[button card].include?(type) ? Card::VARIANTS.fetch(variant, Card::VARIANTS[:tertiary]) : []
            { classes: klasses(*RADIO_LABEL_TYPES.fetch(type), *card_color) }
          end

          def form_field_radio_item_group_classes
            { classes: "contents group" }
          end
        end
      end
    end
  end
end
