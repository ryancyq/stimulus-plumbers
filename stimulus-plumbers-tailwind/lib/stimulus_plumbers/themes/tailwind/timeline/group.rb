# frozen_string_literal: true

module StimulusPlumbers
  module Themes
    module Tailwind
      module Timeline
        module Group
          WRAPPER  = %w[space-y-4].freeze
          SECTION  = %w[
            p-4
            bg-(--sp-color-bg-muted)
            border border-(--sp-color-border)
            rounded-lg
          ].freeze
          DATE     = %w[text-base font-semibold text-(--sp-color-fg)].freeze
          LIST     = %w[mt-3 divide-y divide-(--sp-color-border)].freeze

          private

          def timeline_group_classes              = { classes: klasses(WRAPPER) }
          def timeline_group_section_classes      = { classes: klasses(SECTION) }
          def timeline_group_section_date_classes = { classes: klasses(DATE) }
          def timeline_group_section_list_classes = { classes: klasses(LIST) }
        end
      end
    end
  end
end
