# frozen_string_literal: true

module StimulusPlumbers
  module Helpers
    module AvatarHelper
      def sp_avatar(name: nil, initials: nil, url: nil, color: nil, size: :md, **html_options, &block)
        avatar_renderer.avatar(name: name, initials: initials, url: url, color: color, size: size, **html_options, &block)
      end

      private

      def avatar_renderer
        Components::Avatar::Renderer.new(self)
      end
    end
  end
end
