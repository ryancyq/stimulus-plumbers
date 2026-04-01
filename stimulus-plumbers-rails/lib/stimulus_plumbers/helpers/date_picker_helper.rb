# frozen_string_literal: true

module StimulusPlumbers
  module Helpers
    module DatePickerHelper
      def sp_date_picker_month(**html_options, &block)
        Components::DatePicker::Renderer.new(self).datepicker(**html_options)
      end
    end
  end
end
