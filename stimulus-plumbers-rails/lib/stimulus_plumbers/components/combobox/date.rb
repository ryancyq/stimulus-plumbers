# frozen_string_literal: true

module StimulusPlumbers
  module Components
    class Combobox
      class Date < Plumber::Base
        STIMULUS_CONTROLLER = "combobox-date"
        CALENDAR_OUTLET     = "#{STIMULUS_CONTROLLER}-calendar-month-outlet".freeze
        STIMULUS_ACTION     = [
          "calendar-observer:selected->#{STIMULUS_CONTROLLER}#onSelect",
          "#{STIMULUS_CONTROLLER}:selected->#{Combobox::STIMULUS_CONTROLLER}#onSelect",
          "#{STIMULUS_CONTROLLER}:selected->#{Components::Popover::STIMULUS_CONTROLLER}#closeOnSelect"
        ].join(" ").freeze

        def self.calendar_id_for(panel_id)
          [panel_id, "calendar"].compact.join("_")
        end

        def self.variant
          Combobox.variant(:date)
        end

        def self.options(**overrides)
          variant.opts(**overrides)
        end

        def render(...) = render_date(...)
        def build(...) = build_date(...)

        private

        def render_date(panel_attrs: {}, value: nil, label: "Picker", labelledby: nil)
          calendar_id = self.class.calendar_id_for(panel_attrs[:id])

          template.content_tag(
            :div,
            **merge_html_options(panel_attrs, dialog_attrs(value, calendar_id, label, labelledby))
          ) do
            template.safe_join([navigation, calendar(id: calendar_id)])
          end
        end

        def build_date(panel_attrs: {}, value: nil, label: "Picker", labelledby: nil, &block)
          calendar_id = self.class.calendar_id_for(panel_attrs[:id])
          template.capture(merge_html_options(panel_attrs, dialog_attrs(value, calendar_id, label, labelledby)), &block)
        end

        def dialog_attrs(value, calendar_id, label, labelledby)
          data = {
            controller:      STIMULUS_CONTROLLER,
            CALENDAR_OUTLET  => "##{calendar_id}",
            action:          STIMULUS_ACTION,
            "#{STIMULUS_CONTROLLER}-date-value" => value
          }.compact

          { role: "dialog", aria: labelled_aria(label, labelledby: labelledby), data: data }
        end

        def navigation
          Navigation.new(template).render(
            step:                "month",
            stimulus_controller: STIMULUS_CONTROLLER
          )
        end

        def calendar(**kwargs)
          Calendar.new(template).render(**kwargs)
        end
      end
    end
  end
end
