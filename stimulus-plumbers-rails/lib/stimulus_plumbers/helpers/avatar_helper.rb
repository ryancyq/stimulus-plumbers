# frozen_string_literal: true

module StimulusPlumbers
  module Helpers
    module AvatarHelper
      def sp_avatar(...)
        Components::Avatar.new(self).render(...)
      end
    end
  end
end
