# frozen_string_literal: true

require_relative "schema/ranges"

module StimulusPlumbers
  module Themes
    module Schema
      ACTION_LIST = {
        action_list_item: {
          active: { default: false, range: Ranges::BOOL_RANGE }
        }.freeze,
        action_list:      {}.freeze
      }.freeze

      AVATAR = {
        avatar: {
          size:  { default: :md, range: Ranges::SIZE_RANGE },
          color: { default: nil, range: :avatar_color_range }
        }.freeze
      }.freeze

      BUTTON = {
        button:       {
          variant: { default: :primary, range: %i[primary secondary outline destructive ghost link].freeze },
          size:    { default: :md,      range: Ranges::SIZE_RANGE }
        }.freeze,
        button_group: {
          alignment: { default: :left, range: Ranges::ALIGN_RANGE },
          direction: { default: :row,  range: Ranges::DIR_RANGE }
        }.freeze
      }.freeze

      CALENDAR = {
        calendar:                           {}.freeze,
        calendar_days_of_week:              {}.freeze,
        calendar_days_of_month:             {}.freeze,
        calendar_day:                       {
          today:    { default: false, range: Ranges::BOOL_RANGE },
          selected: { default: false, range: Ranges::BOOL_RANGE },
          outside:  { default: false, range: Ranges::BOOL_RANGE }
        }.freeze,
        calendar_navigation:                {}.freeze,
        calendar_navigation_navigator:      {}.freeze,
        calendar_navigation_navigator_icon: {}.freeze
      }.freeze

      CARD = {
        card:         {}.freeze,
        card_section: {}.freeze
      }.freeze

      COMBOBOX = {
        combobox_option:               {
          selected: { default: false, range: Ranges::BOOL_RANGE },
          disabled: { default: false, range: Ranges::BOOL_RANGE }
        }.freeze,
        combobox_option_group:         {}.freeze,
        combobox_listbox:              {}.freeze,
        combobox_autocomplete_loading: {}.freeze,
        combobox_autocomplete_empty:   {}.freeze,
        combobox_time:                 {}.freeze
      }.freeze

      FORM = {
        form_group:         {
          layout: { default: :stacked, range: Ranges::LAYOUT_RANGE },
          error:  { default: false,    range: Ranges::BOOL_RANGE }
        }.freeze,
        form_label:         {
          required: { default: false, range: Ranges::BOOL_RANGE },
          hidden:   { default: false, range: Ranges::BOOL_RANGE }
        }.freeze,
        form_required_mark: {}.freeze,
        form_details:       {}.freeze,
        form_error:         {}.freeze,
        form_input:         { error: { default: false, range: Ranges::BOOL_RANGE } }.freeze,
        form_textarea:      { error: { default: false, range: Ranges::BOOL_RANGE } }.freeze,
        form_file:          { error: { default: false, range: Ranges::BOOL_RANGE } }.freeze,
        form_select:        { error: { default: false, range: Ranges::BOOL_RANGE } }.freeze,
        form_checkbox:      { error: { default: false, range: Ranges::BOOL_RANGE } }.freeze,
        form_radio:         { error: { default: false, range: Ranges::BOOL_RANGE } }.freeze,
        form_input_group:   { error: { default: false, range: Ranges::BOOL_RANGE } }.freeze,
        form_combobox:      { error: { default: false, range: Ranges::BOOL_RANGE } }.freeze,
        form_input_reveal:  {}.freeze,
        form_button_reveal: {}.freeze,
        form_submit:        {
          variant: { default: :default, range: %i[default button].freeze }
        }.freeze
      }.freeze

      LAYOUT = {
        divider: {}.freeze,
        popover: {}.freeze
      }.freeze
    end
  end
end
