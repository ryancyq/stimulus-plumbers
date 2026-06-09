# frozen_string_literal: true

module StimulusPlumbers
  module Themes
    module Tailwind
      module Form
        GROUP_BASE   = %w[flex gap-(--sp-space-1) mb-(--sp-space-3)].freeze
        GROUP_INLINE = %w[flex-row items-center].freeze

        private

        def form_group_classes(layout: :stacked, **_rest)
          { classes: klasses(*GROUP_BASE, layout == :inline ? GROUP_INLINE : "flex-col") }
        end

        def form_submit_classes(type: :default, variant: :primary)
          { classes: klasses(
            *Button::BASE,
            *Button::LAYOUT,
            *Button::VARIANTS.fetch(variant, Button::VARIANTS[:primary]),
            *Button::TYPES.fetch(type, Button::TYPES[:default]),
            *(type == :card ? [] : Button::SIZES[:md])
          )
}
        end
      end
    end
  end
end
