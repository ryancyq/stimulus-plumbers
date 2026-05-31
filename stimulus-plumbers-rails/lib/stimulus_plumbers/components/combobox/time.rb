# frozen_string_literal: true

module StimulusPlumbers
  module Components
    class Combobox
      class Time < Plumber::Base
        STIMULUS_CONTROLLER = "combobox-time"
        STIMULUS_ACTION     = [
          "#{STIMULUS_CONTROLLER}:selected->#{Combobox::STIMULUS_CONTROLLER}#onSelect",
          "#{STIMULUS_CONTROLLER}:selected->#{Components::Popover::STIMULUS_CONTROLLER}#closeOnSelect"
        ].join(" ").freeze

        def self.variant
          Combobox.variant(:time)
        end

        def self.options(**overrides)
          variant.opts(**overrides)
        end

        def render(...) = render_time(...)
        def build(...) = build_time(...)

        private

        def render_time(panel_attrs: {}, format: :h12, step: 1, value: nil, label: "Picker", labelledby: nil)
          @format = format
          @step   = [1, step.to_i].max
          @time   = parse_time(value)

          attrs = merge_html_options(
            panel_attrs,
            { classes: theme.resolve(:combobox_time).fetch(:classes, "") },
            dialog_attrs(label, labelledby)
          )
          template.content_tag(:div, **attrs) { template.safe_join(drums) }
        end

        def build_time(panel_attrs: {}, label: "Picker", labelledby: nil, **_kwargs, &block)
          attrs = merge_html_options(
            panel_attrs,
            { classes: theme.resolve(:combobox_time).fetch(:classes, "") },
            dialog_attrs(label, labelledby)
          )
          template.capture(attrs, &block)
        end

        def dialog_attrs(label, labelledby)
          {
            role: "dialog",
            aria: labelled_aria(label, labelledby: labelledby),
            data: { controller: STIMULUS_CONTROLLER, action: STIMULUS_ACTION }
          }
        end

        def drums
          cols = [hour_drum, minute_drum]
          cols << period_drum if @format == :h12
          cols
        end

        def render_drum(target, label, items, selected)
          drum.render(
            stimulus_controller: STIMULUS_CONTROLLER,
            target:              target,
            label:               label,
            items:               items,
            selected:            selected
          )
        end

        def hour_drum
          render_drum("hour", "Hour", hour_items, current_hour)
        end

        def minute_drum
          items    = (0...60).step(@step).map { |m| [m.to_s.rjust(2, "0")] * 2 }
          selected = @time ? snap_minute(@time.min).to_s.rjust(2, "0") : nil
          render_drum("minute", "Minute", items, selected)
        end

        def period_drum
          render_drum("period", "Period", [%w[AM AM], %w[PM PM]], @time && (@time.hour < 12 ? "AM" : "PM"))
        end

        def hour_items
          if @format == :h12
            (1..12).map { |h| [h.to_s, h.to_s] }
          else
            (0..23).map { |h| [h.to_s.rjust(2, "0")] * 2 }
          end
        end

        def current_hour
          return nil unless @time

          if @format == :h12
            h = @time.hour % 12
            (h.zero? ? 12 : h).to_s
          else
            @time.hour.to_s.rjust(2, "0")
          end
        end

        def snap_minute(minute)
          return minute if @step == 1

          ((minute.to_f / @step).round * @step) % 60
        end

        def drum
          @drum ||= Time::Drum.new(template)
        end

        def parse_time(value)
          return nil if value.nil? || value.to_s.strip.empty?

          ::Time.parse(value.to_s)
        rescue ArgumentError
          nil
        end
      end
    end
  end
end
