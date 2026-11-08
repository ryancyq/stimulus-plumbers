# frozen_string_literal: true

module StimulusPlumbers
  module Components
    class Combobox
      # The input group around a combobox trigger, with decorative icons.
      class TriggerGroup < Plumber::Base
        def render(icon_leading: nil, icon_trailing: nil, trailing: nil, &block)
          InputGroup.new(template).render(
            leading:  icon_leading ? -> { render_icon(icon_leading) } : nil,
            trailing: trailing || (icon_trailing ? -> { render_icon(icon_trailing) } : nil),
            **theme.resolve(:combobox_trigger_group),
            &block
          )
        end

        private

        def render_icon(name)
          Components::Icon.new(template).render(
            name, classes: theme.resolve(:combobox_trigger_icon).fetch(:classes, ""), aria: { hidden: "true" }
          )
        end
      end
    end
  end
end
