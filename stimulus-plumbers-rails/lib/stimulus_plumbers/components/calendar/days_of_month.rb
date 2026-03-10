# frozen_string_literal: true

module StimulusPlumbers
  module Components
    module Calendar
      class DaysOfMonth < Plumber::Base
        def days_of_month(**kwargs)
          self.html_options = { 
            classes: theme.resolve(:calendar_days_of_month).fetch(:classes, ""),
            **kwargs
          }
          
          template.content_tag(:div, nil, role: "grid", **html_options)
        end
      end
    end
  end
end
