# frozen_string_literal: true

module StimulusPlumbers
  module Themes
    module Avatar
      SCHEMA = {
        avatar: {
          size:  { default: :md,  range: Schema::Ranges::SIZE_RANGE },
          color: { default: nil,  range: :avatar_color_range }
        }.freeze
      }.freeze
    end
  end
end
