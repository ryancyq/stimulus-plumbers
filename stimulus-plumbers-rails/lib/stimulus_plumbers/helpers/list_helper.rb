# frozen_string_literal: true

module StimulusPlumbers
  module Helpers
    module ListHelper
      def sp_list(...)
        Components::List.new(self).render(...)
      end
    end
  end
end
