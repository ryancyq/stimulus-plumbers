# frozen_string_literal: true

module StimulusPlumbers
  module Form
    module Fields
      module Inputs
        module Select
          module Timezone
            def time_zone_select(attribute, priority_zones = nil, options = {}, html_options = {})
              merged = merge_html_options(html_options, field_theme(:form_select))
              super(attribute, priority_zones, options, merged)
            end
          end
        end
      end
    end
  end
end
