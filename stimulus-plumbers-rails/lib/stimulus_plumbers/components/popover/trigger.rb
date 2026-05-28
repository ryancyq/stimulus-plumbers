# frozen_string_literal: true

module StimulusPlumbers
  module Components
    class Popover
      class Trigger < Plumber::Base
        ACTION = [
          "click->popover#toggle",
          "keydown.esc->popover#close"
        ].join(" ").freeze

        def render(panel_id:, haspopup: "dialog", **kwargs, &block)
          html_options = merge_html_options(
            { classes: theme.resolve(:popover_trigger).fetch(:classes, "") },
            { type: "button",
              aria: { haspopup: haspopup, expanded: "false", controls: panel_id },
              data: { popover_target: "trigger", action: ACTION }
},
            kwargs
          )
          template.content_tag(:button, block_given? ? template.capture(&block) : nil, **html_options)
        end
      end
    end
  end
end
