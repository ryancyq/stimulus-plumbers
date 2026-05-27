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
        CHECKBOX      = %w[
          size-(--sp-control-size) rounded-(--sp-radius-sm) border border-(--sp-color-muted-fg)
          text-(--sp-color-primary) focus:ring-2 focus:ring-(--sp-focus-ring-color)
        ].freeze
        RADIO = %w[
          size-(--sp-control-size) border border-(--sp-color-muted-fg) text-(--sp-color-primary)
          focus:ring-2 focus:ring-(--sp-focus-ring-color) focus:outline-none
        ].freeze

        INPUT_GROUP_BASE   = %w[flex items-center overflow-hidden rounded-(--sp-radius-md) border].freeze
        INPUT_GROUP_BORDER = { error: "border-(--sp-color-error)", default: "border-(--sp-color-muted-fg)" }.freeze

        COLLECTION_ITEM_LABEL = %w[
          flex items-center gap-(--sp-space-2)
          text-(length:--sp-text-sm) text-(--sp-color-fg) cursor-pointer py-(--sp-space-0-5)
        ].freeze
        CHOICE_ITEM_DESCRIPTION = %w[
          block text-(length:--sp-text-xs) text-(--sp-color-muted-fg)
        ].freeze

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

        def form_checkbox_classes(**)
          { classes: klasses(*CHECKBOX) }
        end

        def form_radio_classes(**)
          { classes: klasses(*RADIO) }
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

        def form_collection_label_classes
          { classes: klasses(*COLLECTION_ITEM_LABEL) }
        end

        def form_choice_item_description_classes
          { classes: klasses(*CHOICE_ITEM_DESCRIPTION) }
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
