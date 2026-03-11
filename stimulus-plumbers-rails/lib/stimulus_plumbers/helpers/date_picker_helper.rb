# frozen_string_literal: true

module StimulusPlumbers
  module Helpers
    module DatePickerHelper
      def sp_date_picker_month(**html_options, &block)
        date_picker_renderer.month(**html_options, &block)
      end

      private

      def date_picker_renderer
        Components::DatePicker::Renderer.new(self)
      end
    end
  end
end
