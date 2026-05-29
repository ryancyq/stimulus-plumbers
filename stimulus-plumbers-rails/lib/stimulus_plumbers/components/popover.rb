# frozen_string_literal: true

module StimulusPlumbers
  module Components
    class Popover < Plumber::Base
      def render(...)
        render_popover(...)
      end

      private

      def render_popover(interactive: true, **kwargs, &block)
        html_options = merge_html_options(
          { classes: theme.resolve(:popover).fetch(:classes, "") },
          kwargs
        )

        template.content_tag(:div, **html_options) do
          render_popover_with_builder(interactive, &block)
        end
      end

      def render_popover_with_builder(interactive, &block)
        builder = Popover::Builder.new(template)
        yield builder

        content_html = if interactive
                         template.content_tag(:template, builder.content_html)
                       else
                         builder.content_html
                       end
        template.safe_join(
          [
            builder.activator_html,
            content_html
          ]
        )
      end
    end
  end
end
