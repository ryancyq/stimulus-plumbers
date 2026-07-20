# frozen_string_literal: true

module StimulusPlumbers
  module Components
    class Button < Plumber::Base
      module IconLayout
        private

        def build_layout(slots, &block)
          @template.safe_join(
            [
              render_icon_slot(slots, :icon_leading),
              @template.capture(&block),
              render_icon_slot(slots, :icon_trailing)
            ]
          )
        end

        def render_icon_slot(slots, name)
          slots.resolve(name) do |value|
            next value unless Components::Icon.icon_name?(value)

            Components::Icon.new(@template).render(
              value,
              size:    :sm,
              classes: theme.resolve(:button_icon).fetch(:classes, ""),
              aria:    { hidden: "true" }
            )
          end
        end
      end
    end
  end
end
