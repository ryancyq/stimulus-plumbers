# frozen_string_literal: true

module StimulusPlumbers
  module Themes
    class Tailwind < Base
      require_relative "tailwind/avatar"
      require_relative "tailwind/button"
      require_relative "tailwind/calendar"
      require_relative "tailwind/card"
      require_relative "tailwind/form"
      require_relative "tailwind/layout"

      include Avatar
      include Button
      include Calendar
      include Card
      include Form
      include Layout

      private

      def klasses(*classes)
        classes.flatten.reject(&:blank?).join(" ")
      end
    end
  end
end
