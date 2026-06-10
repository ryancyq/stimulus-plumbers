# frozen_string_literal: true

module StimulusPlumbers
  module Helpers
    module CardHelper
      def sp_card(...)
        Components::Card.new(self).render(...)
      end
    end
  end
end
