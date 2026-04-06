# frozen_string_literal: true

module StimulusPlumbers
  module Helpers
    module DatePickerHelper
      def sp_date_picker_month(record = nil, attribute = nil, **html_options)
        Components::DatePicker::Renderer.new(self).render(
          calendar_id: sp_dom_id(record, "#{attribute}_date"),
          **html_options
        )
      end
    end
  end
end
