# frozen_string_literal: true

module StimulusPlumbers
  module Components
    class Popover
      class Panel < Plumber::Base
        def render(panel_id:, tag: :div, **kwargs, &block)
          template.content_tag(
            tag,
            block_given? ? template.capture(panel_id, &block) : nil,
            **panel_attrs(panel_id, **kwargs)
          )
        end

        def build(panel_id:, **kwargs, &block)
          template.capture(panel_attrs(panel_id, **kwargs), &block)
        end

        private

        def panel_attrs(panel_id, **kwargs)
          merge_html_options(
            { id: panel_id, hidden: "" },
            { classes: theme.resolve(:popover).fetch(:classes, "") },
            { data: { popover_target: "panel" } },
            kwargs
          )
        end
      end
    end
  end
end
