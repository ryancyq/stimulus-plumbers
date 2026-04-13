# frozen_string_literal: true

module StimulusPlumbers
  module Themes
    module Calendar
      SCHEMA = {
        calendar_day: {
          today:    { default: false, range: Schema::Ranges::BOOL_RANGE },
          selected: { default: false, range: Schema::Ranges::BOOL_RANGE },
          outside:  { default: false, range: Schema::Ranges::BOOL_RANGE }
        }.freeze
      }.freeze
    end
  end
end
