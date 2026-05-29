# frozen_string_literal: true

module StimulusPlumbers
  module Components
    class Combobox
      class Date < Plumber::Base
        STIMULUS_CONTROLLER = "combobox-date"
        CALENDAR_OUTLET = "#{STIMULUS_CONTROLLER}-calendar-month-outlet".freeze

        def self.default_opts
          { input: { data: { combobox_date_date_value: nil } } }
        end

        def self.haspopup = "dialog"
        def self.popup_id(panel_id) = panel_id

        def self.calendar_id_for(panel_id)
          [panel_id, "calendar"].compact.join("_")
        end

        def render(...)
          render_date(...)
        end

        private

        def render_date(panel_id: nil, panel_attrs: {}, value: nil, label: "Picker", labelledby: nil)
          calendar_id = self.class.calendar_id_for(panel_id)

          data = {
            controller:          STIMULUS_CONTROLLER,
            CALENDAR_OUTLET  => "##{calendar_id}",
            action:              [
              "calendar-month-observer:selected->#{STIMULUS_CONTROLLER}#onSelect",
              "#{STIMULUS_CONTROLLER}:selected->#{Combobox::STIMULUS_CONTROLLER}#onSelect",
              "#{STIMULUS_CONTROLLER}:selected->#{Components::Popover::STIMULUS_CONTROLLER}#closeOnSelect"
            ].join(" "),
            "#{STIMULUS_CONTROLLER}-date-value" => value
          }.compact

          aria = { label: (label unless labelledby), labelledby: labelledby }.compact

          template.content_tag(
            :div,
            **merge_html_options(panel_attrs, { role: "dialog", aria: aria, data: data })
          ) do
            template.safe_join([navigation, calendar_month(id: calendar_id)])
          end
        end

        def navigation
          DatePicker::Navigation.new(template).render(
            step:                "month",
            stimulus_controller: STIMULUS_CONTROLLER
          )
        end

        def calendar_month(**kwargs)
          Calendar.new(template).month(**kwargs)
        end
      end
    end
  end
end
