# frozen_string_literal: true

module StimulusPlumbers
  module Form
    module Fields
      module Inputs
        module Select
          module Timezone
            def time_zone_select(attribute, priority_zones = nil, options = {}, html_opts = {})
              html_options = merge_html_options(theme.resolve(:form_select), html_opts)
              super(attribute, priority_zones, options, html_options)
            end
          end
        end
      end
    end
  end
end
