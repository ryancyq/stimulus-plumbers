# frozen_string_literal: true

module StimulusPlumbers
  module Components
    class Popover < Plumber::Base
      STIMULUS_CONTROLLER = "popover"

      class << self
        def panel_id_for(trigger_id)
          [trigger_id, "popover"].compact.join("_")
        end
      end

      def render(...)
        render_popover(...)
      end

      def build(panel_id: nil, mode: :auto, placement: :block_end_start, &block)
        @panel_id     = panel_id || self.class.panel_id_for(template.sp_dom_id)
        @trigger_html = nil
        @panel_html   = nil
        @mode         = validate_mode!(mode)
        @placement    = placement
        yield self if block_given?
        template.safe_join([@trigger_html, @panel_html])
      end

      def trigger(haspopup: nil, controls: @panel_id, **kwargs, &block)
        if block_given? && block.arity == 1
          attrs = { panel_id: @panel_id, data: { popover_target: "trigger" } }
          attrs[:aria] = { haspopup: haspopup, expanded: "false", controls: controls } unless haspopup.nil?
          attrs = merge_html_options(attrs, kwargs)
          @trigger_html = template.capture(attrs, &block)
        else
          @trigger_html = Popover::Trigger.new(template).render(
            panel_id: @panel_id, haspopup: haspopup, controls: controls, **kwargs, &block
          )
        end
      end

      def panel(**kwargs, &block)
        @panel_html = Popover::Panel.new(template).render(
          panel_id: @panel_id, mode: @mode, placement: @placement, **kwargs, &block
        )
      end

      def build_panel(**kwargs, &block)
        @panel_html = Popover::Panel.new(template).build(
          panel_id: @panel_id, mode: @mode, placement: @placement, **kwargs, &block
        )
      end

      private

      def render_popover(panel_id: nil, mode: :auto, placement: :block_end_start, **kwargs, &block)
        html_options = merge_html_options(
          theme.resolve(:popover_wrapper),
          kwargs,
          { data: { controller: STIMULUS_CONTROLLER } }
        )
        template.content_tag(:div, **html_options) do
          build(panel_id: panel_id, mode: mode, placement: placement, &block)
        end
      end

      def validate_mode!(mode)
        normalized = mode.to_sym if mode.respond_to?(:to_sym)
        return normalized if %i[auto manual].include?(normalized)

        raise ArgumentError, "popover mode must be one of: auto, manual"
      end
    end
  end
end
