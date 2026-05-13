# frozen_string_literal: true

module StimulusPlumbers
  module Helpers
    module AvatarHelper
      def sp_avatar(name: nil, initials: nil, url: nil, color: nil, size: :md, **html_options, &block)
        avatar_renderer.render(name: name, initials: initials, url: url, color: color, size: size, **html_options, &block)
      end

      private

      def avatar_renderer
        Components::Avatar.new(self)
      end
    end
  end
end
