# frozen_string_literal: true

module StimulusPlumbers
  module Themes
    module Calendar
      SCHEMA = {
        calendar:                           {}.freeze,
        calendar_days_of_week:              {}.freeze,
        calendar_days_of_month:             {}.freeze,
        calendar_day:                       {
          today:    { default: false, range: Schema::Ranges::BOOL_RANGE },
          selected: { default: false, range: Schema::Ranges::BOOL_RANGE },
          outside:  { default: false, range: Schema::Ranges::BOOL_RANGE }
        }.freeze,
        calendar_navigation:                {}.freeze,
        calendar_navigation_navigator:      {}.freeze,
        calendar_navigation_navigator_icon: {}.freeze
      }.freeze
    end
  end
end
