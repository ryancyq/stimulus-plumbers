# frozen_string_literal: true

module StimulusPlumbers
  module Components
    class Popover < Plumber::Base
      STIMULUS_CONTROLLER = "popover"

      def self.panel_id_for(trigger_id = nil)
        [trigger_id || SecureRandom.hex(8), "popover"].join("_")
      end

      def render(...) = render_popover(...)

      def build(panel_id: nil, &block)
        @panel_id     = panel_id || self.class.panel_id_for
        @trigger_html = nil
        @panel_html   = nil
        yield self
        template.safe_join([@trigger_html, @panel_html].compact)
      end

      def trigger(haspopup: "dialog", controls: @panel_id, **kwargs, &block)
        if block_given? && block.arity == 1
          attrs = {
            panel_id: @panel_id,
            aria:     { haspopup: haspopup, expanded: "false", controls: controls },
            data:     { popover_target: "trigger", action: Popover::Trigger::STIMULUS_ACTION }
          }
          @trigger_html = template.capture(attrs, &block)
        else
          @trigger_html = Popover::Trigger.new(template).render(
            panel_id: @panel_id, haspopup: haspopup, **kwargs, &block
          )
        end
      end

      def panel(**kwargs, &block)
        @panel_html = Popover::Panel.new(template).render(panel_id: @panel_id, **kwargs, &block)
      end

      def build_panel(**kwargs, &block)
        @panel_html = Popover::Panel.new(template).build(panel_id: @panel_id, **kwargs, &block)
      end

      private

      def render_popover(panel_id: nil, close_on_select: nil, **kwargs, &block)
        data = { controller: STIMULUS_CONTROLLER }
        data[:popover_close_on_select_value] = close_on_select unless close_on_select.nil?
        html_options = merge_html_options(
          theme.resolve(:popover_wrapper),
          kwargs,
          { data: data }
        )
        template.content_tag(:div, **html_options) do
          build(panel_id: panel_id, &block)
        end
      end
    end
  end
end
