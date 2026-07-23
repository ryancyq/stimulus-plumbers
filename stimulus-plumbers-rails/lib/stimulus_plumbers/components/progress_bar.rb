# frozen_string_literal: true

module StimulusPlumbers
  module Components
    class ProgressBar < Plumber::Base
      include Progress::Shared

      def render(...)
        render_bar(...)
      end

      def render_segmented(value:, segments:, min: 0, max: 100, mode: :discrete, indeterminate: false, ramp: nil, **kwargs)
        html_options = merge_html_options(
          theme.resolve(:progress_segmented),
          kwargs,
          progress_stimulus_data(
            value:                          value,
            min:                            min,
            max:                            max,
            variant:                        "segmented",
            "progress-segment-mode-value":  mode,
            "progress-indeterminate-value": indeterminate
          ),
          { role: "progressbar", aria: progress_aria(value: value, min: min, max: max, indeterminate: indeterminate) }
        )
        slots = ramp_intents(ramp, segments).map { |intent| render_segment(intent: intent) }
        template.content_tag(:div, template.safe_join(slots), **html_options)
      end

      private

      def render_bar(value:, min: 0, max: 100, indeterminate: false, **kwargs)
        html_options = merge_html_options(
          theme.resolve(:progress_bar),
          kwargs,
          progress_stimulus_data(
            value: value, min: min, max: max, variant: "bar", "progress-indeterminate-value": indeterminate
          ),
          { role: "progressbar", aria: progress_aria(value: value, min: min, max: max, indeterminate: indeterminate) }
        )
        template.content_tag(:div, render_fill, **html_options)
      end

      # `data-intent` is a theme-independent styling hook the theme colors via attribute variants.
      def render_fill(intent: nil)
        data = { "progress-target": "fill" }
        data[:intent] = intent if intent
        template.content_tag(:div, nil, **merge_html_options(theme.resolve(:progress_bar_fill), { data: data }))
      end

      # Slots are aria-hidden — the container owns the progressbar ARIA.
      def render_segment(intent: nil)
        template.content_tag(
          :div,
          render_fill(intent: intent),
          **merge_html_options(theme.resolve(:progress_segment), { aria: { hidden: true } })
        )
      end

      # `:strength` buckets each slot into danger/warning/success thirds by position; nil = uncolored.
      def ramp_intents(ramp, count)
        return Array.new(count) unless ramp == :strength

        Array.new(count) do |i|
          case (i + 1).fdiv(count)
          when ..(1.0 / 3) then :danger
          when ..(2.0 / 3) then :warning
          else :success
          end
        end
      end
    end
  end
end
