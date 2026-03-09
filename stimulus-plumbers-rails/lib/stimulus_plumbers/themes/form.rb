# frozen_string_literal: true

module StimulusPlumbers
  module Themes
    module Form
      SCHEMA = {
        form_group:         {
          layout: { default: :stacked, range: Schema::Ranges::LAYOUT_RANGE },
          state:  { default: :default, range: Schema::Ranges::STATE_RANGE }
        }.freeze,
        form_label:         { required: { default: false, range: Schema::Ranges::BOOL_RANGE } }.freeze,
        form_required_mark: {}.freeze,
        form_details:       {}.freeze,
        form_error:         {}.freeze,
        form_input:         { state: { default: :default, range: Schema::Ranges::STATE_RANGE } }.freeze,
        form_textarea:      { state: { default: :default, range: Schema::Ranges::STATE_RANGE } }.freeze,
        form_file:          { state: { default: :default, range: Schema::Ranges::STATE_RANGE } }.freeze,
        form_select:        { state: { default: :default, range: Schema::Ranges::STATE_RANGE } }.freeze,
        form_checkbox:      { state: { default: :default, range: Schema::Ranges::STATE_RANGE } }.freeze,
        form_radio:         { state: { default: :default, range: Schema::Ranges::STATE_RANGE } }.freeze,
        form_actor:         { state: { default: :default, range: Schema::Ranges::STATE_RANGE } }.freeze,
        form_input_reveal:  {}.freeze,
        form_reveal_button: {}.freeze
      }.freeze
    end
  end
end
