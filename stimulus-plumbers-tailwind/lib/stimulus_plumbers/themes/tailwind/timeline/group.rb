# frozen_string_literal: true

module StimulusPlumbers
  module Themes
    module Tailwind
      module Timeline
        module Group
          CONTAINER       = %w[flex flex-col gap-y-4].freeze
          SECTION         = %w[
            p-4
            bg-(--sp-color-bg-muted)
            border border-(--sp-color-border)
            rounded-lg
          ].freeze
          DATE            = %w[text-base font-semibold text-(--sp-color-fg)].freeze
          LIST_VERTICAL   = %w[
            pt-3 flex flex-col
            divide-y divide-(--sp-color-border)
            [&>li]:py-2 [&>li]:first:pt-0 [&>li]:last:pb-0
          ].freeze
          LIST_HORIZONTAL = %w[pt-3 flex gap-x-4].freeze

          private

          def timeline_group_classes
            { classes: class_names(CONTAINER) }
          end

          def timeline_group_section_classes
            { classes: class_names(SECTION) }
          end

          def timeline_group_section_date_classes
            { classes: class_names(DATE) }
          end

          def timeline_group_section_list_classes(orientation: :vertical)
            list = orientation.to_sym == :horizontal ? LIST_HORIZONTAL : LIST_VERTICAL
            { classes: class_names(list) }
          end
        end
      end
    end
  end
end
