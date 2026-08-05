# frozen_string_literal: true

module StimulusPlumbers
  module Components
    class ProgressBar < Plumber::Base
      include Progress::Shared

      def render(...)
        render_bar(...)
      end

      def render_segmented(
        value:,
        segments:,
        min: 0,
        max: 100,
        mode: :discrete,
        indeterminate: false,
        ramp: nil,
        format: nil,
        **kwargs
      )
        validate_segments!(segments, format)
        current = clamp(value, min, max)
        html_options = merge_html_options(
          theme.resolve(:progress_segmented),
          kwargs,
          segmented_stimulus_data(current, min, max, mode, indeterminate),
          { role: "progressbar", aria: progress_aria(value: current, min: min, max: max, indeterminate: indeterminate) }
        )
        slots = ramp_intents(ramp, segments).map { |intent| render_segment(intent: intent) }
        template.content_tag(:div, template.safe_join(slots), **html_options)
      end

      private

      def validate_segments!(segments, format)
        raise ArgumentError, "format: is not supported with segments:" unless format.nil?
        raise ArgumentError, "segments must be a positive integer" unless segments.is_a?(Integer) && segments.positive?
      end

      def segmented_stimulus_data(current, min, max, mode, indeterminate)
        progress_stimulus_data(
          value:                          current,
          min:                            min,
          max:                            max,
          variant:                        "segmented",
          "progress-segment-mode-value":  mode,
          "progress-indeterminate-value": indeterminate
        )
      end

      def render_bar(value:, min: 0, max: 100, indeterminate: false, format: nil, **kwargs)
        validate_format!(format)
        current      = clamp(value, min, max)
        text         = value_text(format, current, min, max) unless indeterminate
        html_options = bar_html_options(current, min, max, indeterminate, format, text, kwargs)
        template.content_tag(:div, bar_body(format, text), **html_options)
      end

      def bar_body(format, text)
        format.nil? ? render_fill : template.safe_join([render_fill, render_value(text)])
      end

      def bar_html_options(current, min, max, indeterminate, format, text, kwargs)
        # `percent` omits aria-valuetext — AT derives the percentage from aria-valuenow itself.
        valuetext = text unless format&.to_sym == :percent
        aria      = progress_aria(value: current, min: min, max: max, indeterminate: indeterminate, valuetext: valuetext)
        merge_html_options(
          theme.resolve(:progress_bar, labelled: !format.nil?),
          kwargs,
          bar_stimulus_data(current, min, max, indeterminate, format),
          { role: "progressbar", aria: aria }
        )
      end

      def bar_stimulus_data(current, min, max, indeterminate, format)
        progress_stimulus_data(
          value:                          current,
          min:                            min,
          max:                            max,
          variant:                        "bar",
          "progress-indeterminate-value": indeterminate,
          **(format.nil? ? {} : { "progress-format-value": format })
        )
      end

      # aria-hidden: the value reaches AT via aria-valuenow/aria-valuetext, not this span.
      def render_value(text)
        template.content_tag(
          :span,
          text,
          **merge_html_options(
            theme.resolve(:progress_bar_value),
            { data: { "progress-target": "value" }, aria: { hidden: true } }
          )
        )
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
