# frozen_string_literal: true

module StimulusPlumbers
  module Themes
    module Tailwind
      module Form
        INPUT_BASE = %w[
          w-full rounded-md border px-3 py-2 text-sm text-gray-900
          bg-white focus:outline-none focus:ring-2 focus:ring-offset-0
        ].freeze
        INPUT_ERROR   = %w[border-red-700 focus:ring-red-700].freeze
        INPUT_DEFAULT = %w[border-gray-500 focus:ring-blue-700].freeze

        GROUP_BASE    = %w[flex gap-1 mb-3].freeze
        GROUP_INLINE  = %w[flex-row items-center].freeze

        LABEL         = %w[text-sm font-medium text-gray-900].freeze
        REQUIRED_MARK = %w[text-red-700 ml-0.5].freeze
        DETAILS       = %w[text-xs text-gray-600].freeze
        ERROR_TEXT    = %w[text-xs text-red-700].freeze
        CHECKBOX      = %w[size-4 rounded border-gray-500 text-blue-700].freeze
        RADIO         = %w[size-4 border-gray-500 text-blue-700].freeze

        ACTOR_BASE    = %w[flex items-center overflow-hidden rounded-md border].freeze
        ACTOR_BORDER  = { error: "border-red-700", default: "border-gray-500" }.freeze

        INPUT_REVEAL = %w[
          flex-1 border-0 bg-transparent px-3 py-2 text-sm text-gray-900 focus:outline-none
        ].freeze
        BUTTON_REVEAL = %w[
          self-stretch border-0 bg-transparent px-3 cursor-pointer text-gray-600 hover:text-gray-900 text-sm
        ].freeze
        SUBMIT_LINK = %w[cursor-pointer text-sm font-medium text-gray-900 hover:underline].freeze

        private

        def form_group_classes(layout: :stacked, **_rest)
          { classes: klasses(*GROUP_BASE, layout == :inline ? GROUP_INLINE : "flex-col") }
        end

        def form_label_classes(**)
          { classes: klasses(*LABEL) }
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

        def form_actor_classes(error: false)
          { classes: klasses(*ACTOR_BASE, ACTOR_BORDER[error ? :error : :default]) }
        end

        def form_input_reveal_classes
          { classes: klasses(*INPUT_REVEAL) }
        end

        def form_button_reveal_classes
          { classes: klasses(*BUTTON_REVEAL) }
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
