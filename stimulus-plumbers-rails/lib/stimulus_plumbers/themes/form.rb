# frozen_string_literal: true

module StimulusPlumbers
  module Themes
    module Form
      SCHEMA = {
        form_group:         {
          layout: { default: :stacked, range: Schema::Ranges::LAYOUT_RANGE },
          error:  { default: false,    range: Schema::Ranges::BOOL_RANGE }
        }.freeze,
        form_label:         { required: { default: false, range: Schema::Ranges::BOOL_RANGE } }.freeze,
        form_required_mark: {}.freeze,
        form_details:       {}.freeze,
        form_error:         {}.freeze,
        form_input:         { error: { default: false, range: Schema::Ranges::BOOL_RANGE } }.freeze,
        form_textarea:      { error: { default: false, range: Schema::Ranges::BOOL_RANGE } }.freeze,
        form_file:          { error: { default: false, range: Schema::Ranges::BOOL_RANGE } }.freeze,
        form_select:        { error: { default: false, range: Schema::Ranges::BOOL_RANGE } }.freeze,
        form_checkbox:      { error: { default: false, range: Schema::Ranges::BOOL_RANGE } }.freeze,
        form_radio:         { error: { default: false, range: Schema::Ranges::BOOL_RANGE } }.freeze,
        form_actor:         { error: { default: false, range: Schema::Ranges::BOOL_RANGE } }.freeze,
        form_input_reveal:  {}.freeze,
        form_button_reveal: {}.freeze,
        form_submit:        {
          variant: { default: :default, range: %i[default button].freeze }
        }.freeze
      }.freeze
    end
  end
end
