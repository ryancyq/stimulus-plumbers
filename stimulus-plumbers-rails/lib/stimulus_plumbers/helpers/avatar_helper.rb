# frozen_string_literal: true

module StimulusPlumbers
  module Helpers
    module AvatarHelper
      def sp_avatar(...)
        avatar_renderer.render(...)
      end

      private

      def avatar_renderer
        Components::Avatar.new(self)
      end
    end
  end
end
