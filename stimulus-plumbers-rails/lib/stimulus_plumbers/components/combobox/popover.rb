# frozen_string_literal: true

module StimulusPlumbers
  module Components
    class Combobox
      class Popover < Plumber::Base
        def render(...)
          render_popover(...)
        end

        private

        def render_popover(
          stimulus_controller:,
          id:,
          tag: :div,
          role: nil,
          label: nil,
          labelledby: nil,
          content: nil,
          data: {},
          **kwargs,
          &block
        )
          opts = {}
          opts[:role] = role if role
          if labelledby
            opts[:aria] = { labelledby: labelledby }
          elsif label
            opts[:aria] = { label: label }
          end

          html_options = merge_html_options(
            { id: id, hidden: "" },
            { classes: theme.resolve(:popover).fetch(:classes, "") },
            { classes: theme.resolve(:combobox_popover).fetch(:classes, "") },
            { data: { "#{stimulus_controller}_target": "popover" } },
            { data: data },
            opts,
            kwargs
          )

          html_content = block_given? ? template.capture(id, &block) : content
          template.content_tag(tag, html_content, **html_options)
        end
      end
    end
  end
end
