# frozen_string_literal: true

module StimulusPlumbers
  module Components
    class Popover < Plumber::Base
      def render(interactive: true, **kwargs, &block)
        html_options = merge_html_options(
          { classes: theme.resolve(:popover).fetch(:classes, "") },
          kwargs
        )

        builder = Popover::Builder.new(template)
        template.capture(builder, &block)

        template.content_tag(:div, **html_options) do
          template.safe_join([builder.activator_html, wrap_content(interactive, builder)])
        end
      end

      private

      def wrap_content(interactive, builder)
        if interactive
          template.content_tag(:template, builder.content_html)
        else
          builder.content_html
        end
      end
    end
  end
end
