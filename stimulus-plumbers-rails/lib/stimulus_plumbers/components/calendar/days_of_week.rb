# frozen_string_literal: true

module StimulusPlumbers
  module Components
    module Calendar
      class DaysOfWeek < Plumber::Base
        def days_of_week(**kwargs)
          self.html_options = { 
            classes: theme.resolve(:calendar_days_of_week).fetch(:classes, ""),
            **kwargs
          }
          
          template.content_tag(:div, nil, **html_options)
        end
      end
    end
  end
end
