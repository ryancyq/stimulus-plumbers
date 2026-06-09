# frozen_string_literal: true

module StimulusPlumbers
  module Themes
    module Tailwind
      module Button
        module Group
          LAYOUTS = {
            inline:  %w[
              inline-flex rounded-(--sp-radius-md) shadow-(--sp-shadow-xs)
              [&>*:not(:first-child)]:-ml-px
              [&>*]:rounded-none
              [&>*:first-child]:rounded-s-(--sp-radius-md)
              [&>*:last-child]:rounded-e-(--sp-radius-md)
            ].freeze,
            stacked: %w[
              flex flex-col rounded-(--sp-radius-md) shadow-(--sp-shadow-xs)
              [&>*:not(:first-child)]:-mt-px
              [&>*]:rounded-none
              [&>*:first-child]:rounded-t-(--sp-radius-md)
              [&>*:last-child]:rounded-b-(--sp-radius-md)
            ].freeze
          }.freeze

          private

          def button_group_classes(layout: :inline)
            {
              classes: klasses(*LAYOUTS.fetch(layout, LAYOUTS[:inline]))
            }
          end
        end
      end
    end
  end
end
