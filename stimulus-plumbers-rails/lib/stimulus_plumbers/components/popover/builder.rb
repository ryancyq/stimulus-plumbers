# frozen_string_literal: true

module StimulusPlumbers
  module Components
    class Popover
      class Builder
        attr_reader :trigger_html, :panel_html, :panel_id

        def initialize(template, panel_id: nil)
          @template     = template
          @panel_id     = panel_id || "_#{SecureRandom.hex(8)}_panel"
          @trigger_html = nil
          @panel_html   = nil
        end

        # No block / zero-arity block: renders a wired <button>; block becomes button content.
        # One-arity block: yields { panel_id:, aria:, data: } — caller wires their own element.
        def trigger(haspopup: "dialog", controls: @panel_id, **kwargs, &block)
          if block_given? && block.arity == 1
            attrs = {
              panel_id: @panel_id,
              aria:     { haspopup: haspopup, expanded: "false", controls: controls },
              data:     { popover_target: "trigger", action: Popover::Trigger::STIMULUS_ACTION }
            }
            @trigger_html = @template.capture(attrs, &block)
          else
            @trigger_html = Popover::Trigger.new(@template).render(
              panel_id: @panel_id, haspopup: haspopup, **kwargs, &block
            )
          end
        end

        def panel(**kwargs, &block)
          @panel_html = Popover::Panel.new(@template).render(panel_id: @panel_id, **kwargs, &block)
        end

        def build_panel(**kwargs, &block)
          @panel_html = Popover::Panel.new(@template).build(panel_id: @panel_id, **kwargs, &block)
        end
      end
    end
  end
end
