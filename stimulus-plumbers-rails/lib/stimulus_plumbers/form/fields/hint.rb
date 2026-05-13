# frozen_string_literal: true

module StimulusPlumbers
  module Form
    module Fields
      class Hint < Components::Plumber::Base
        def render(text:, id:)
          klass = theme.resolve(:form_details).fetch(:classes, "")
          template.content_tag(:p, text, id: id, class: klass.presence)
        end
      end
    end
  end
end
