# frozen_string_literal: true

module StimulusPlumbers
  module Components
    class Popover
      class Panel < Plumber::Base
        def render(
          panel_id:,
          mode: :auto,
          placement: :block_end_start,
          tag: :div,
          role: nil,
          aria_label: nil,
          aria_labelledby: nil,
          **kwargs,
          &block
        )
          template.content_tag(
            tag,
            block_given? ? template.capture(panel_id, &block) : nil,
            **panel_attrs(
              panel_id,
              mode:            mode,
              placement:       placement,
              role:            role,
              aria_label:      aria_label,
              aria_labelledby: aria_labelledby,
              **kwargs
            )
          )
        end

        def build(
          panel_id:,
          mode: :auto,
          placement: :block_end_start,
          role: nil,
          aria_label: nil,
          aria_labelledby: nil,
          **kwargs,
          &block
        )
          template.capture(
            panel_attrs(
              panel_id,
              mode:            mode,
              placement:       placement,
              role:            role,
              aria_label:      aria_label,
              aria_labelledby: aria_labelledby,
              **kwargs
            ),
            &block
          )
        end

        private

        def panel_attrs(panel_id, mode:, placement:, role:, aria_label:, aria_labelledby:, **kwargs)
          merge_html_options(
            {
              id:      panel_id,
              popover: mode.to_s,
              role:    role,
              aria:    { label: aria_label, labelledby: aria_labelledby }.compact
            },
            theme.resolve(:popover, placement: placement),
            { data: { popover_target: "panel" } },
            kwargs
          )
        end
      end
    end
  end
end
