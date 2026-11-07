# frozen_string_literal: true

module StimulusPlumbers
  module Form
    module Fields
      module Inputs
        module Select
          module Timezone
            def time_zone_select(attribute, priority_zones = nil, options = {}, html_options = {})
              html_options = merge_html_options(theme.resolve(:form_select), html_options)
              super
            end
          end
        end
      end
    end
  end
end
