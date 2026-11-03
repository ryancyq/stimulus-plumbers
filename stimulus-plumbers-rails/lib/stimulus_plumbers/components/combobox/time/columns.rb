# frozen_string_literal: true

module StimulusPlumbers
  module Components
    class Combobox
      class Time
        # The hour, minute, and AM/PM columns.
        class Columns < Plumber::Base
          # `value` is [hour, minute] or nil; a minute off `step` chooses no minute. Columns are `controller`
          # targets.
          def render(id:, controller:, value:, step:, twelve_hour:)
            @id           = id
            @controller   = controller
            @step         = step
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
              column("minute", minutes, (pad(minute) if minute && (minute % @step).zero?)),
              (column("meridiem", meridiems, @hour && (@hour < 12 ? "AM" : "PM")) if @twelve_hour)
            ].compact
          end

          def hours
            @twelve_hour ? (1..12).map { |hour| [hour.to_s] * 2 } : (0..23).map { |hour| [pad(hour)] * 2 }
          end

          def minutes
            (0...60).step(@step).map { |minute| [pad(minute)] * 2 }
          end

          # Labels come from the gem's keys, then Rails' `time.am`/`time.pm`.
          def meridiems
            [[t("am", default: :"time.am"), "AM"], [t("pm", default: :"time.pm"), "PM"]]
          end

          def hour_value(hour)
            @twelve_hour ? (((hour - 1) % 12) + 1).to_s : pad(hour)
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
              theme.resolve(:combobox_time_column, type: name == "meridiem" ? :meridiem : :unit),
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
