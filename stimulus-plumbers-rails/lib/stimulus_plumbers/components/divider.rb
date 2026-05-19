# frozen_string_literal: true

module StimulusPlumbers
  module Components
    class Divider < Plumber::Base
      def render(**kwargs)
        html_options = merge_html_options(
          { classes: theme.resolve(:divider).fetch(:classes, "") },
          kwargs
        )

        template.tag.hr(**html_options)
      end
    end
  end
end
