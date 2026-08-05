# frozen_string_literal: true

module StimulusPlumbers
  module Themes
    module Tailwind
      module Form
        module Input
          # ── Standalone input ──────────────────────────────────────────────────
          INPUT = %w[
            w-full rounded-(--sp-radius-md) border px-(--sp-space-3) py-(--sp-space-2)
            text-(length:--sp-text-sm) text-(--sp-color-fg) bg-(--sp-color-bg)
            focus:outline-none focus:ring-(length:--sp-focus-ring-width) focus:ring-offset-0
          ].freeze
          INPUT_DEFAULT = %w[
            border-(--sp-color-muted-fg) hover:border-(--sp-color-fg)
            focus:ring-(--sp-focus-ring-color)
          ].freeze
          INPUT_ERROR = %w[border-(--sp-color-error) focus:ring-(--sp-color-error)].freeze

          # ── Floating input ────────────────────────────────────────────────────
          FLOATING_INPUT = %w[
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
          FLOATING_INPUT_DEFAULT = %w[
            border-(--sp-color-muted-fg) hover:border-(--sp-color-fg)
            focus:border-(--sp-color-primary)
          ].freeze
          FLOATING_INPUT_ERROR = %w[border-(--sp-color-error)].freeze

          # ── Input group ───────────────────────────────────────────────────────
          INPUT_GROUP        = %w[flex items-center overflow-hidden rounded-(--sp-radius-md) border].freeze
          INPUT_GROUP_BORDER = { error: "border-(--sp-color-error)", default: "border-(--sp-color-muted-fg)" }.freeze

          # ── Floating input group ──────────────────────────────────────────────
          FLOATING_INPUT_GROUP = %w[flex items-center overflow-hidden peer].freeze
          FLOATING_INPUT_GROUP_TYPES = {
            filled:   %w[rounded-t-(--sp-radius-md) bg-(--sp-color-bg-muted) border-0 border-b-2].freeze,
            outlined: %w[rounded-(--sp-radius-md) border].freeze,
            standard: %w[rounded-none bg-transparent border-0 border-b-2].freeze
          }.freeze
          FLOATING_INPUT_GROUP_DEFAULT = %w[
            border-(--sp-color-muted-fg) hover:border-(--sp-color-fg)
            focus-within:border-(--sp-color-primary)
          ].freeze
          FLOATING_INPUT_GROUP_ERROR = %w[border-(--sp-color-error)].freeze

          # ── Combobox wrappers ─────────────────────────────────────────────────
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

          # ── Range ─────────────────────────────────────────────────────────────
          # A slider is a track and a thumb, so it takes none of INPUT's box chrome.
          # WebKit has no filled-track pseudo-element: the fill is a gradient stopped at
          # --sp-progress-percent (set by the progress controller). Firefox has
          # ::-moz-range-progress and uses that instead.
          # Must stay on one line: Tailwind scans source text, so a class split across a string
          # continuation never appears contiguously and is silently dropped from the build.
          # rubocop:disable Layout/LineLength
          RANGE_FILL = "[&::-webkit-slider-runnable-track]:bg-[linear-gradient(to_right,var(--sp-color-primary)_0_calc(var(--sp-progress-percent,0)*1%),transparent_0)]"
          # rubocop:enable Layout/LineLength

          RANGE = [
            "w-full appearance-none bg-transparent cursor-pointer",
            "focus:outline-none",
            "focus-visible:outline-none",
            "focus-visible:ring-(length:--sp-focus-ring-width)",
            "focus-visible:ring-(--sp-focus-ring-color)",
            "disabled:opacity-50 disabled:cursor-not-allowed",
            # WebKit track + thumb
            "[&::-webkit-slider-runnable-track]:h-2",
            "[&::-webkit-slider-runnable-track]:rounded-full",
            "[&::-webkit-slider-runnable-track]:bg-(--sp-color-muted)",
            RANGE_FILL,
            "[&::-webkit-slider-thumb]:appearance-none",
            "[&::-webkit-slider-thumb]:size-4",
            "[&::-webkit-slider-thumb]:rounded-full",
            "[&::-webkit-slider-thumb]:bg-(--sp-color-primary)",
            # Centers a 16px thumb on an 8px track.
            "[&::-webkit-slider-thumb]:-mt-1",
            # Firefox track + native fill + thumb
            "[&::-moz-range-track]:h-2",
            "[&::-moz-range-track]:rounded-full",
            "[&::-moz-range-track]:bg-(--sp-color-muted)",
            "[&::-moz-range-progress]:h-2",
            "[&::-moz-range-progress]:rounded-full",
            "[&::-moz-range-progress]:bg-(--sp-color-primary)",
            "[&::-moz-range-thumb]:size-4",
            "[&::-moz-range-thumb]:border-0",
            "[&::-moz-range-thumb]:rounded-full",
            "[&::-moz-range-thumb]:bg-(--sp-color-primary)"
          ].freeze

          # The readout sits outside the input, so the input's own disabled:opacity-50 never
          # reaches it — without this a disabled slider keeps a full-strength readout.
          RANGE_GROUP = %w[
            flex items-center gap-(--sp-space-3)
            [&:has(input:disabled)>span]:opacity-50
          ].freeze

          # Sits beside the track, not over it — no pill background needed.
          # Shares Progress::VALUE_TEXT, resolved at call time since progress.rb loads later.
          RANGE_VALUE = %w[shrink-0 text-(--sp-color-fg)].freeze

          # ── Choice inputs ─────────────────────────────────────────────────────
          CHECKBOX_TYPES = {
            default: [
              *Control::ACCENT,
              "size-(--sp-control-size) rounded-(--sp-radius-sm) shrink-0",
              "border border-(--sp-color-border) bg-(--sp-color-muted)",
              "focus:ring-(length:--sp-focus-ring-width) focus:ring-(--sp-focus-ring-color) focus:outline-none",
              "disabled:opacity-50 disabled:cursor-not-allowed cursor-pointer"
            ].freeze,
            button:  [
              *Control::ACCENT,
              "size-(--sp-control-size) rounded-(--sp-radius-sm) shrink-0",
              "border border-(--sp-color-border) bg-(--sp-color-muted)",
              "focus:ring-(length:--sp-focus-ring-width) focus:ring-(--sp-focus-ring-color) focus:outline-none",
              "disabled:opacity-50 disabled:cursor-not-allowed cursor-pointer"
            ].freeze,
            card:    %w[
              size-(--sp-control-size) rounded-(--sp-radius-sm) shrink-0
              border border-(--sp-color-border) bg-(--sp-color-muted)
              [accent-color:var(--card-ring)] cursor-pointer
              checked:border-(--card-ring)
              focus:ring-(length:--sp-focus-ring-width) focus:ring-(--card-ring) focus:outline-none
              disabled:opacity-50 disabled:cursor-not-allowed cursor-pointer
            ].freeze
          }.freeze

          RADIO_TYPES = {
            default: [
              *Control::ACCENT,
              "size-(--sp-control-size) rounded-full shrink-0",
              "focus:ring-(length:--sp-focus-ring-width) focus:ring-(--sp-focus-ring-color) focus:outline-none",
              "disabled:opacity-50 disabled:cursor-not-allowed"
            ].freeze,
            button:  %w[hidden].freeze,
            card:    %w[hidden].freeze
          }.freeze

          # ── Utility buttons ───────────────────────────────────────────────────
          BUTTON_REVEAL = [
            *Control::BASE,
            "inline-flex items-center justify-center",
            "focus-visible:ring-(--sp-focus-ring-color)",
            "self-stretch px-(--sp-space-2) border-0 bg-transparent cursor-pointer text-(--sp-color-muted-fg)",
            "rounded-(--sp-radius-sm) hover:bg-(--sp-color-muted) hover:text-(--sp-color-fg)"
          ].freeze
          BUTTON_CLEAR = [
            *Control::BASE,
            "inline-flex items-center justify-center",
            "focus-visible:ring-(--sp-focus-ring-color)",
            "self-stretch px-(--sp-space-2) border-0 bg-transparent cursor-pointer text-(--sp-color-muted-fg)",
            "rounded-(--sp-radius-sm) hover:bg-(--sp-color-muted) hover:text-(--sp-color-fg)"
          ].freeze

          private

          def form_field_input_classes(floating: nil, error: false)
            if floating
              { classes: klasses(
                *FLOATING_INPUT,
                *FLOATING_INPUT_TYPES.fetch(floating, []),
                *(error ? FLOATING_INPUT_ERROR : FLOATING_INPUT_DEFAULT)
              )
}
            else
              { classes: klasses(*INPUT, *(error ? INPUT_ERROR : INPUT_DEFAULT)) }
            end
          end

          def form_field_input_textarea_classes(floating: nil, error: false)
            form_field_input_classes(floating: floating, error: error)
          end

          def form_field_input_file_classes(floating: nil, error: false)
            form_field_input_classes(floating: floating, error: error)
          end

          # Not form_field_input_classes — a progressbar is display-only, so it takes none of the
          # text-input chrome (border, padding, focus ring); the track styling comes from progress_bar.
          def form_field_input_progress_classes
            { classes: klasses("w-full") }
          end

          def form_field_input_range_classes
            { classes: klasses(*RANGE) }
          end

          def form_field_input_range_group_classes
            { classes: klasses(*RANGE_GROUP) }
          end

          def form_field_input_range_value_classes
            { classes: klasses(*Progress::VALUE_TEXT, *RANGE_VALUE) }
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

          def input_group_classes(error: false, floating: nil)
            if floating
              color = error ? FLOATING_INPUT_GROUP_ERROR : FLOATING_INPUT_GROUP_DEFAULT
              { classes: klasses(*FLOATING_INPUT_GROUP, *FLOATING_INPUT_GROUP_TYPES.fetch(floating, []), *color) }
            else
              { classes: klasses(*INPUT_GROUP, INPUT_GROUP_BORDER[error ? :error : :default]) }
            end
          end

          def form_field_input_combobox_classes(floating: nil, error: false)
            if floating
              form_field_input_combobox_floating_classes(floating: floating, error: error)
            else
              {
                classes: klasses(
                  *INPUT,
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
                *FLOATING_INPUT,
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
                "peer",
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
