# frozen_string_literal: true

module StimulusPlumbers
  module Components
    class Combobox
      class Trigger < Plumber::Base
        def render(...)
          render_trigger(...)
        end

        private

        def render_trigger(
          stimulus_controller:,
          popover_id:,
          haspopup:,
          readonly: true,
          aria_autocomplete: nil,
          aria_label: nil,
          aria: {},
          id: nil,
          data: {},
          icon_leading: nil,
          icon_trailing: nil,
          **kwargs
        )
          input_html = render_input(
            stimulus_controller:, popover_id:, haspopup:,
            readonly:, aria_autocomplete:, aria_label:,
            aria:, id:, data:, **kwargs
          )

          return input_html unless icon_leading || icon_trailing

          render_trigger_group(icon_leading, icon_trailing) { input_html }
        end

        def render_input(
          stimulus_controller:,
          popover_id:,
          haspopup:,
          readonly:,
          aria_autocomplete:,
          aria_label:,
          aria:,
          id:,
          data:,
          **kwargs
        )
          stimulus_data = {
            "#{stimulus_controller}_target": "trigger",
            input_formatter_target:          "input",
            action:                          "focus->#{stimulus_controller}#open keydown.esc->#{stimulus_controller}#close"
          }

          trigger_aria = { haspopup: haspopup, expanded: "false", controls: popover_id }
          trigger_aria[:autocomplete] = aria_autocomplete if aria_autocomplete
          trigger_aria[:label]        = aria_label        if aria_label

          template.tag.input(
            **merge_html_options(
              { classes: theme.resolve(:combobox_trigger).fetch(:classes, "") },
              {
                id:       id,
                type:     "text",
                readonly: (readonly ? true : nil),
                role:     "combobox",
                aria:     trigger_aria.deep_merge(aria),
                data:     stimulus_data
              },
              { data: data },
              kwargs
            )
          )
        end

        def render_trigger_group(icon_leading, icon_trailing, &block)
          InputGroup.new(template).render(
            leading:  icon_leading  ? -> { render_trigger_icon(icon_leading) }  : nil,
            trailing: icon_trailing ? -> { render_trigger_icon(icon_trailing) } : nil,
            **theme.resolve(:combobox_trigger_group)
          ) { template.capture(&block) }
        end

        def render_trigger_icon(name)
          Icon.new(template).render(name: name, aria: { hidden: "true" })
        end
      end
    end
  end
end
