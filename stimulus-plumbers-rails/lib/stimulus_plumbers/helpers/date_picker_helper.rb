# frozen_string_literal: true

module StimulusPlumbers
  module Helpers
    module DatePickerHelper
      def sp_date_picker_month(record = nil, attribute = nil, **html_options)
        calendar_id        = sp_dom_id(record, [attribute, "date"].filter(&:presence).join("_"))
        calendar_dialog_id = "#{calendar_id}_dialog"
        Components::DatePicker::Renderer.new(self).render(
          calendar_id:        calendar_id,
          calendar_dialog_id: calendar_dialog_id,
          **html_options
        )
      end
    end
  end
end
