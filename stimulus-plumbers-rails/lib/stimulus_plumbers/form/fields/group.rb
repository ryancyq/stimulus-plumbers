# frozen_string_literal: true

module StimulusPlumbers
  module Form
    module Fields
      class Group < Plumber::Base
        def render(layout: :stacked, error: false, &block)
          html_options = merge_html_options(theme.resolve(:form_group, layout: layout, error: error))
          template.content_tag(:div, **html_options, &block)
        end
      end
    end
  end
end
