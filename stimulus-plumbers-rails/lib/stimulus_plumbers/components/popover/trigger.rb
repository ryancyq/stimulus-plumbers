# frozen_string_literal: true

module StimulusPlumbers
  module Components
    class Popover
      class Trigger < Plumber::Base
        STIMULUS_ACTION = [
          "click->#{STIMULUS_CONTROLLER}#toggle",
          "keydown.esc->#{STIMULUS_CONTROLLER}#close"
        ].join(" ").freeze

        def render(panel_id:, haspopup: "dialog", **kwargs, &block)
          html_options = merge_html_options(
            { classes: theme.resolve(:popover_trigger).fetch(:classes, "") },
            {
              type: "button",
              aria: { haspopup: haspopup, expanded: "false", controls: panel_id },
              data: { popover_target: "trigger", action: STIMULUS_ACTION }
            },
            kwargs
          )
          template.content_tag(:button, block_given? ? template.capture(&block) : nil, **html_options)
        end
      end
    end
  end
end
