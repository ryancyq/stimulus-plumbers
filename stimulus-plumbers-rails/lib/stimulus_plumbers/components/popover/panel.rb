# frozen_string_literal: true

module StimulusPlumbers
  module Components
    class Popover
      class Panel < Plumber::Base
        def render(panel_id:, tag: :div, **kwargs, &block)
          html_options = merge_html_options(
            { id: panel_id, hidden: "" },
            { classes: theme.resolve(:popover).fetch(:classes, "") },
            kwargs
          )
          template.content_tag(tag, block_given? ? template.capture(panel_id, &block) : nil, **html_options)
        end
      end
    end
  end
end
