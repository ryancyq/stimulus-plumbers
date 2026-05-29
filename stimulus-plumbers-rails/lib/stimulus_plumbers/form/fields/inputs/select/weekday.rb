# frozen_string_literal: true

module StimulusPlumbers
  module Form
    module Fields
      module Inputs
        module Select
          module Weekday
            if ActionView.version >= Gem::Version.new("7.1")
              def weekday_select(attribute, options = {}, html_options = {})
                merged = merge_html_options(html_options, field_theme(:form_select))
                super(attribute, options, merged)
              end
            end
          end
        end
      end
    end
  end
end
