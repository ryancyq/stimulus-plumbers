# frozen_string_literal: true

module StimulusPlumbers
  module Helpers
    module CalendarHelper
      def sp_calendar_month(**html_options, &block)
        calendar_renderer.month(**html_options, &block)
      end

      private

      def calendar_renderer
        Components::Calendar::Renderer.new(self)
      end
    end
  end
end
