# frozen_string_literal: true

module StimulusPlumbers
  module Components
    class Combobox
      # A read-only time input whose popover holds hour, minute, and AM/PM columns.
      class Time < Temporal
        STIMULUS_CONTROLLER = "combobox-time"
        FORMAT              = "time"
        ICON                = "clock"
        POPOVER_KEY         = :combobox_time_popover
        ACTIONS             = [
          "popover:before-open->#{STIMULUS_CONTROLLER}#onOpening",
          "popover:opened->#{STIMULUS_CONTROLLER}#onOpened"
        ].freeze
        COLUMN_ACTION       = "keydown->#{STIMULUS_CONTROLLER}#onNavigate click->#{STIMULUS_CONTROLLER}#onSelect".freeze

        # `step:` is the minute interval; a minute off it chooses no minute.
        def render(step: 1, **kwargs)
          @step = [1, step.to_i].max
          super(**kwargs)
        end

        private

        # [hour, minute] from a time or an "HH:MM" string; anything else renders as text.
        def parse(value)
          return [value.hour, value.min] if value.respond_to?(:hour) && value.respond_to?(:min)

          match = value.to_s.match(%r{\A(\d{1,2}):(\d{2})})
          [match[1].to_i, match[2].to_i] if match && match[1].to_i < 24 && match[2].to_i < 60
        end

        def canonical((hour, minute))
          format("%<hour>02d:%<minute>02d", hour: hour, minute: minute)
        end

        # The columns follow `hourCycle` or `hour12`, 12-hour by default.
        def format_options(format)
          return super unless format.respond_to?(:to_h)

          { hourCycle: "h12" }.merge(super)
        end

        def twelve_hour?
          return true unless @format.is_a?(Hash)

          @format.fetch(:hour12) { %w[h11 h12].include?(@format[:hourCycle].to_s) }
        end

        def render_panel(panel_attrs)
          template.content_tag(:div, **merge_html_options(panel_attrs, theme.resolve(:combobox_time))) do
            template.safe_join(columns)
          end
        end

        def columns
          hour, minute = @value
          [
            column("hour", hours, hour && hour_value(hour)),
            column("minute", minutes, (pad(minute) if minute && (minute % @step).zero?)),
            (column("meridiem", meridiems, hour && (hour < 12 ? "AM" : "PM")) if twelve_hour?)
          ].compact
        end

        def hours
          twelve_hour? ? (1..12).map { |hour| [hour.to_s] * 2 } : (0..23).map { |hour| [pad(hour)] * 2 }
        end

        def minutes
          (0...60).step(@step).map { |minute| [pad(minute)] * 2 }
        end

        # Labels come from the gem's keys, then Rails' `time.am`/`time.pm`.
        def meridiems
          [[t("am", default: :"time.am"), "AM"], [t("pm", default: :"time.pm"), "PM"]]
        end

        def hour_value(hour)
          twelve_hour? ? (((hour - 1) % 12) + 1).to_s : pad(hour)
        end

        def column(name, items, selected)
          options = items.map do |label, value|
            Options::Option.new(template).render(
              id: option_id(name, value), label: label, value: value, selected: value == selected
            )
          end
          template.content_tag(:ul, template.safe_join(options), **column_attrs(name, selected))
        end

        def column_attrs(name, selected)
          merge_html_options(
            theme.resolve(:combobox_listbox),
            theme.resolve(:combobox_time_drum, type: name == "meridiem" ? :meridiem : :unit),
            {
              role:     "listbox",
              tabindex: "0",
              aria:     { label: t("#{name}_label"), activedescendant: (option_id(name, selected) if selected) }.compact,
              data:     { "#{STIMULUS_CONTROLLER}-target" => name, action: COLUMN_ACTION }
            }
          )
        end

        def option_id(name, value)
          "#{@id}_#{name}_#{value}"
        end

        def pad(number)
          number.to_s.rjust(2, "0")
        end

        def t(key, **options)
          I18n.t("stimulus_plumbers.combobox.time.#{key}", **options)
        end
      end
    end
  end
end
