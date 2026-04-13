# frozen_string_literal: true

module StimulusPlumbers
  module Themes
    module ActionList
      SCHEMA = {
        action_list_item: {
          active: { default: false, range: Schema::Ranges::BOOL_RANGE }
        }.freeze,
        action_list:      {}.freeze
      }.freeze
    end
  end
end
