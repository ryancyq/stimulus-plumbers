# frozen_string_literal: true

module StimulusPlumbers
  module Helpers
    module IconHelper
      def sp_icon(name:, **kwargs)
        Components::Icon.new(self).render(name: name, **kwargs)
      end
    end
  end
end
