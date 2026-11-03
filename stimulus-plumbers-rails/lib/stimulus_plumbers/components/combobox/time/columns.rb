# frozen_string_literal: true

module StimulusPlumbers
  module Components
    class Combobox
      class Time
        # The hour, minute, and AM/PM columns. An option is unavailable when no available time matches it and
        # the choices it depends on: an hour depends on AM or PM, a minute on AM or PM and the hour.
        class Columns < Plumber::Base
          HOURS = (0..23).to_a.freeze

          # `value` is [hour, minute] or nil; a minute off the step chooses no minute. Columns are `controller`
          # targets.
          def render(id:, controller:, value:, availability:, twelve_hour:)
            @id           = id
            @controller   = controller
            @availability = availability
            @twelve_hour  = twelve_hour
            @hour, minute = value
            template.safe_join(columns(minute))
          end

          private

          attr_reader :controller

          def action
            "keydown->#{controller}#onNavigate click->#{controller}#onSelect"
          end

          def columns(minute)
            [
              column("hour", hours, @hour && hour_value(@hour)),
              column("minute", minutes, (pad(minute) if minute && (minute % @availability.step).zero?)),
              (column("meridiem", meridiems, meridiem) if @twelve_hour)
            ].compact
          end

          def hours
            @twelve_hour ? (1..12).map { |hour| [hour.to_s] * 2 } : HOURS.map { |hour| [pad(hour)] * 2 }
          end

          def minutes
            (0...60).step(@availability.step).map { |minute| [pad(minute)] * 2 }
          end

          # Labels come from the gem's keys, then Rails' `time.am`/`time.pm`.
          def meridiems
            [[t("am", default: :"time.am"), "AM"], [t("pm", default: :"time.pm"), "PM"]]
          end

          def hour_value(hour)
            @twelve_hour ? (((hour - 1) % 12) + 1).to_s : pad(hour)
          end

          def meridiem
            @hour && (@hour < 12 ? "AM" : "PM") if @twelve_hour
          end

          def column(name, items, selected)
            options = items.map do |label, value|
              Options::Option.new(template).render(
                id:       option_id(name, value),
                label:    label,
                value:    value,
                selected: value == selected,
                disabled: disabled?(name, value)
              )
            end
            template.content_tag(:ul, template.safe_join(options), **column_attrs(name, selected))
          end

          def disabled?(name, value)
            case name
            when "meridiem" then hours_disabled?(hours_for(nil, value))
            when "hour"     then hours_disabled?(hours_for(value, meridiem))
            else
              (@hour ? [@hour] : HOURS).all? do |hour|
                @availability.disabled?("#{pad(hour)}:#{value}")
              end
            end
          end

          def hours_disabled?(hours)
            hours.all? { |hour| @availability.hour_disabled?(hour) }
          end

          # The 24-hour hours an hour value and a meridiem stand for; either may be nil.
          def hours_for(hour, meridiem)
            return hour ? [hour.to_i] : HOURS unless @twelve_hour

            HOURS.select do |each|
              (hour.nil? || each % 12 == hour.to_i % 12) && (meridiem.nil? || (each >= 12) == (meridiem == "PM"))
            end
          end

          def column_attrs(name, selected)
            merge_html_options(
              theme.resolve(:combobox_listbox),
              theme.resolve(:combobox_time_drum, type: name == "meridiem" ? :meridiem : :unit),
              {
                role:     "listbox",
                tabindex: "0",
                aria:     { label: t("#{name}_label"), activedescendant: (option_id(name, selected) if selected) }.compact,
                data:     { "#{controller}-target" => name, action: action }
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
end
