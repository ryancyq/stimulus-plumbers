# frozen_string_literal: true

module StimulusPlumbers
  module Helpers
    module AvatarHelper
      def sp_avatar(**html_options, &block)
        avatar_renderer.render(**html_options, &block)
      end

      private

      def avatar_renderer
        Components::Avatar.new(self)
      end
    end
  end
end
