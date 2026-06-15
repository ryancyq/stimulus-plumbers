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

        module Metadata
          module_function

          def haspopup = "dialog"
          def popup_id_for(panel_id) = panel_id
          def trigger_icon = "clock"
          def trigger_options = {}

          def stimulus_data(_panel_id, options)
            {
              input_formatter_format_value:  "time",
              input_formatter_options_value: { format: options.fetch(:format, :h12) }.to_json
            }
          end
        end

        def render(...) = render_time(...)

        private

        def render_time(panel_attrs: {}, format: :h12, step: 1, value: nil, label: "Picker", labelledby: nil)
          step = [1, step.to_i].max
          time = parse_time(value)

          attrs = merge_html_options(panel_attrs, theme.resolve(:combobox_time), dialog_attrs(label, labelledby))
          template.content_tag(:div, **attrs) { template.safe_join(drums(format, step, time)) }
        end

        def dialog_attrs(label, labelledby)
          {
            role: "dialog",
            aria: labelled_aria(label, labelledby: labelledby),
            data: { controller: STIMULUS_CONTROLLER, action: STIMULUS_ACTION }
          }
        end

        def drums(format, step, time)
          cols = [hour_drum(format, time), minute_drum(step, time)]
          cols << period_drum(time) if format == :h12
          cols
        end

        def hour_drum(format, time)
          items = if format == :h12
                    (1..12).map { |h| [h.to_s] * 2 }
                  else
                    (0..23).map { |h| [h.to_s.rjust(2, "0")] * 2 }
                  end
          render_drum("hour", t("hour_label"), items, selected_hour(format, time))
        end

        def minute_drum(step, time)
          items    = (0...60).step(step).map { |m| [m.to_s.rjust(2, "0")] * 2 }
          selected = time ? round_minute(time.min, step).to_s.rjust(2, "0") : nil
          render_drum("minute", t("minute_label"), items, selected)
        end

        def period_drum(time)
          items    = [[t("am"), "AM"], [t("pm"), "PM"]]
          selected = time && (time.hour < 12 ? "AM" : "PM")
          render_drum("period", t("period_label"), items, selected)
        end

        def selected_hour(format, time)
          return nil unless time

          if format == :h12
            h = time.hour % 12
            (h.zero? ? 12 : h).to_s
          else
            time.hour.to_s.rjust(2, "0")
          end
        end

        def round_minute(minute, step)
          return minute if step == 1

          ((minute.to_f / step).round * step) % 60
        end

        def render_drum(target, label, items, selected)
          attrs = merge_html_options(
            theme.resolve(:combobox_listbox),
            theme.resolve(:combobox_time_drum, type: target == "period" ? :period : :unit),
            {
              role:     "listbox",
              tabindex: "0",
              aria:     { label: label },
              data:     { "#{STIMULUS_CONTROLLER}_target": target }
            },
            { data: { action: "click->#{STIMULUS_CONTROLLER}#select keydown->#{STIMULUS_CONTROLLER}#onNavigate" } }
          )
          template.content_tag(:ul, **attrs) do
            template.safe_join(
              items.map do |text, value|
                Options::Option.new(template).render(label: text, value: value, selected: value.to_s == selected.to_s)
              end
            )
          end
        end

        def parse_time(value)
          return nil if value.nil? || value.to_s.strip.empty?

          ::Time.parse(value.to_s)
        rescue ArgumentError
          nil
        end

        def t(key)
          I18n.t("stimulus_plumbers.combobox.time.#{key}")
        end
      end
    end
  end
end
