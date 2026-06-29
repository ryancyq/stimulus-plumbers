# frozen_string_literal: true

module StimulusPlumbers
  module Components
    class Combobox
      class Date < Plumber::Base
        STIMULUS_CONTROLLER     = "combobox-date"
        CALENDAR_MONTH_OUTLET   = "#{STIMULUS_CONTROLLER}-calendar-month-outlet".freeze
        CALENDAR_YEAR_OUTLET    = "#{STIMULUS_CONTROLLER}-calendar-year-outlet".freeze
        CALENDAR_DECADE_OUTLET  = "#{STIMULUS_CONTROLLER}-calendar-decade-outlet".freeze
        STIMULUS_ACTION         = [
          "calendar-month:selected->#{STIMULUS_CONTROLLER}#onDaySelect",
          "calendar-year:selected->#{STIMULUS_CONTROLLER}#onMonthSelect",
          "calendar-decade:selected->#{STIMULUS_CONTROLLER}#onYearSelect",
          "#{STIMULUS_CONTROLLER}:selected->#{Combobox::STIMULUS_CONTROLLER}#onSelect",
          "#{STIMULUS_CONTROLLER}:selected->#{Components::Popover::STIMULUS_CONTROLLER}#closeOnSelect"
        ].join(" ").freeze

        def self.month_id_for(panel_id)   = [panel_id, "calendar_month"].compact.join("_")
        def self.year_id_for(panel_id)    = [panel_id, "calendar_year"].compact.join("_")
        def self.decade_id_for(panel_id)  = [panel_id, "calendar_decade"].compact.join("_")

        module Metadata
          module_function

          def haspopup = "dialog"
          def popup_id_for(panel_id) = panel_id
          def trigger_icon = "calendar"
          def trigger_options = {}
          def stimulus_data(_panel_id, _options) = { input_formatter_format_value: "date" }
        end

        def render(...) = render_date(...)

        private

        def render_date(panel_attrs: {}, value: nil, label: nil, labelledby: nil)
          panel_id  = panel_attrs[:id]
          month_id  = self.class.month_id_for(panel_id)
          year_id   = self.class.year_id_for(panel_id)
          decade_id = self.class.decade_id_for(panel_id)

          template.content_tag(
            :div,
            **merge_html_options(panel_attrs, dialog_attrs(value, month_id, year_id, decade_id, label, labelledby))
          ) do
            template.safe_join([navigation, calendar(month_id: month_id, year_id: year_id, decade_id: decade_id)])
          end
        end

        def dialog_attrs(value, month_id, year_id, decade_id, label, labelledby)
          data = {
            controller:             STIMULUS_CONTROLLER,
            CALENDAR_MONTH_OUTLET   => "##{month_id}",
            CALENDAR_YEAR_OUTLET    => "##{year_id}",
            CALENDAR_DECADE_OUTLET  => "##{decade_id}",
            action:                 STIMULUS_ACTION,
            "#{STIMULUS_CONTROLLER}-date-value" => value
          }.compact

          resolved_label = label || I18n.t("stimulus-plumbers.combobox.date.dialog_label")
          { role: "dialog", aria: labelled_aria(resolved_label, labelledby: labelledby), data: data }
        end

        def navigation
          Navigation.new(template).render(
            step:                "month",
            stimulus_controller: STIMULUS_CONTROLLER
          )
        end

        def calendar(month_id:, year_id:, decade_id:)
          cal = Calendar.new(template)
          template.safe_join(
            [
              cal.month(id: month_id),
              cal.year(id: year_id),
              cal.decade(id: decade_id)
            ]
          )
        end
      end
    end
  end
end
