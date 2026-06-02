# frozen_string_literal: true

module StimulusPlumbers
  module Form
    module Fields
      module Inputs
        module Select
          module Weekday
            if ActionView.version >= Gem::Version.new("7.1")
              def weekday_select(attribute, options = {}, html_opts = {})
                html_options = merge_html_options(theme.resolve(:form_select), html_opts)
                super(attribute, options, html_options)
              end
            end
          end
        end
      end
    end
  end
end
