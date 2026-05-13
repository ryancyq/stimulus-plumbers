# frozen_string_literal: true

module StimulusPlumbers
  module Form
    module Fields
      class Error < Components::Plumber::Base
        def render(message:, id:)
          klass = theme.resolve(:form_error).fetch(:classes, "")
          template.content_tag(:p, message, id: id, class: klass.presence, role: "alert")
        end
      end
    end
  end
end
