# frozen_string_literal: true

module StimulusPlumbers
  module Components
    class Popover
      class Trigger < Plumber::Base
        def render(panel_id:, haspopup: nil, controls: panel_id, **kwargs, &block)
          attrs = {
            type:          "button",
            popovertarget: panel_id,
            data:          { popover_target: "trigger" }
          }
          attrs[:aria] = { haspopup: haspopup, expanded: "false", controls: controls } unless haspopup.nil?
          html_options = merge_html_options(theme.resolve(:popover_trigger), attrs, kwargs)
          template.content_tag(:button, block_given? ? template.capture(&block) : nil, **html_options)
        end
      end
    end
  end
end
