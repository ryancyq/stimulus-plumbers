# frozen_string_literal: true

module StimulusPlumbers
  module Form
    module Fields
      class Group < Components::Plumber::Base
        def render(layout: :stacked, error: false, &block)
          klass = theme.resolve(:form_group, layout: layout, error: error).fetch(:classes, "")
          template.content_tag(:div, class: klass.presence, &block)
        end
      end
    end
  end
end
