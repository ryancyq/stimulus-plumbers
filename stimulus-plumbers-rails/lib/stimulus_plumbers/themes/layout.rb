# frozen_string_literal: true

module StimulusPlumbers
  module Themes
    module Layout
      SCHEMA = {
        action_list_item: {
          active: { default: false, range: Schema::Ranges::BOOL_RANGE }
        }.freeze,
        action_list:      {}.freeze,
        divider:          {}.freeze,
        popover:          {}.freeze
      }.freeze
    end
  end
end
