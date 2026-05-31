# frozen_string_literal: true

module StimulusPlumbers
  module Components
    class Popover < Plumber::Base
      STIMULUS_CONTROLLER = "popover"

      def render(...) = render_popover(...)

      # Yields builder; returns trigger + panel HTML with no outer wrapper.
      # Use this when the caller owns the outer element (e.g. Combobox).
      def build(panel_id: nil, &block)
        builder = Popover::Builder.new(template, panel_id: panel_id)
        yield builder
        template.safe_join([builder.trigger_html, builder.panel_html])
      end

      private

      def render_popover(panel_id: nil, close_on_select: nil, **kwargs, &block)
        data = { controller: STIMULUS_CONTROLLER }
        data[:popover_close_on_select_value] = close_on_select unless close_on_select.nil?
        html_options = merge_html_options(
          {
            classes: theme.resolve(:popover_wrapper).fetch(:classes, ""),
            data:    data
          },
          kwargs
        )
        template.content_tag(:div, **html_options) do
          build(panel_id: panel_id, &block)
        end
      end
    end
  end
end
