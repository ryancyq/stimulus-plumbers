# frozen_string_literal: true

require_relative "tailwind/control"
require_relative "tailwind/checklist"
require_relative "tailwind/list"
require_relative "tailwind/ordered_list"
require_relative "tailwind/avatar"
require_relative "tailwind/button"
require_relative "tailwind/button/group"
require_relative "tailwind/calendar"
require_relative "tailwind/card"
require_relative "tailwind/combobox"
require_relative "tailwind/form"
require_relative "tailwind/form/field"
require_relative "tailwind/form/input"
require_relative "tailwind/icon"
require_relative "tailwind/indicator"
require_relative "tailwind/layout"
require_relative "tailwind/link"
require_relative "tailwind/progress"
require_relative "tailwind/timeline"

module StimulusPlumbers
  module Themes
    class TailwindTheme < Base
      include Tailwind::Checklist
      include Tailwind::List
      include Tailwind::OrderedList
      include Tailwind::Combobox
      include Tailwind::Avatar
      include Tailwind::Button
      include Tailwind::Button::Group
      include Tailwind::Calendar
      include Tailwind::Card
      include Tailwind::Form
      include Tailwind::Form::Field
      include Tailwind::Form::Input
      include Tailwind::Icon
      include Tailwind::Indicator
      include Tailwind::Layout
      include Tailwind::Link
      include Tailwind::Progress
      include Tailwind::Timeline
      include Tailwind::Timeline::Group

      private

      def klasses(*classes)
        classes.flatten.reject(&:blank?).join(" ")
      end
    end
  end
end
