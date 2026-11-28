# frozen_string_literal: true

module StimulusPlumbers
  module Form
    module Fields
      module Inputs
        module Select
          module Weekday
            if ActionView.version >= Gem::Version.new("7.1")
              def weekday_select(attribute, options = {}, html_options = {})
                html_options = merge_html_options(theme.resolve(:form_select), html_options)
                super
              end
            end
          end
        end
      end
    end
  end
end
