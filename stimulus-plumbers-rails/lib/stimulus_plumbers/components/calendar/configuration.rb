# frozen_string_literal: true

module StimulusPlumbers
  module Components
    class Calendar
      # The calendar's options; `link` builds a period URL from a date and a view.
      Configuration = Struct.new(
        :id,
        :displayed,
        :selected,
        :today,
        :availability,
        :selectable,
        :show_other_months,
        :first_day_of_week,
        :url,
        :link,
        keyword_init: true
      )
    end
  end
end
