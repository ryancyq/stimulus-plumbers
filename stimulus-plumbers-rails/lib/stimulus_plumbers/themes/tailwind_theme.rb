# frozen_string_literal: true

require_relative "tailwind/action_list"
require_relative "tailwind/avatar"
require_relative "tailwind/button"
require_relative "tailwind/calendar"
require_relative "tailwind/card"
require_relative "tailwind/form"
require_relative "tailwind/layout"

module StimulusPlumbers
  module Themes
    class TailwindTheme < Base
      include Tailwind::ActionList
      include Tailwind::Avatar
      include Tailwind::Button
      include Tailwind::Calendar
      include Tailwind::Card
      include Tailwind::Form
      include Tailwind::Layout

      private

      def klasses(*classes)
        classes.flatten.reject(&:blank?).join(" ")
      end
    end
  end
end
