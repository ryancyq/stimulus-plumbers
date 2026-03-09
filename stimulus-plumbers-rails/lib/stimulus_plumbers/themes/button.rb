# frozen_string_literal: true

module StimulusPlumbers
  module Themes
    module Button
      SCHEMA = {
        button:       {
          variant: { default: :primary, range: %i[primary secondary outline destructive ghost link].freeze },
          size:    { default: :md,      range: Schema::Ranges::SIZE_RANGE }
        }.freeze,
        button_group: {
          alignment: { default: :left, range: Schema::Ranges::ALIGN_RANGE },
          direction: { default: :row,  range: Schema::Ranges::DIR_RANGE }
        }.freeze
      }.freeze
    end
  end
end
