# frozen_string_literal: true

require_relative "schema/ranges"
require_relative "schema/form/ranges"
require_relative "schema/icon"

module StimulusPlumbers
  module Themes
    module Schema
      ACTION_LIST = {
        action_list_item: {
          active: { default: false, range: Ranges::BOOL }
        }.freeze,
        action_list:      {}.freeze
      }.freeze

      AVATAR = {
        avatar: {
          size:  { default: :md, range: Ranges::SIZE },
          color: { default: nil, range: :avatar_color_range }
        }.freeze
      }.freeze

      BUTTON = {
        button:       {
          variant: { default: :primary, range: Ranges::BUTTON_VARIANT },
          size:    { default: :md,      range: Ranges::SIZE }
        }.freeze,
        button_group: {
          alignment: { default: :left, range: Ranges::FLEX_ALIGN },
          direction: { default: :row,  range: Ranges::FLEX_DIRECTION }
        }.freeze
      }.freeze

      CALENDAR = {
        calendar:                           {}.freeze,
        calendar_days_of_week:              {}.freeze,
        calendar_week:                      {}.freeze,
        calendar_days_of_month:             {}.freeze,
        calendar_day:                       {
          today:    { default: false, range: Ranges::BOOL },
          selected: { default: false, range: Ranges::BOOL },
          outside:  { default: false, range: Ranges::BOOL }
        }.freeze,
        calendar_navigation:                {}.freeze,
        calendar_navigation_navigator:      {}.freeze,
        calendar_navigation_navigator_icon: {
          name: { default: "arrow-left", range: :icon_range }
        }.freeze
      }.freeze

      CARD = {
        card:         {}.freeze,
        card_section: {}.freeze
      }.freeze

      COMBOBOX = {
        combobox_trigger:              {}.freeze,
        combobox_option:               {
          selected: { default: false, range: Ranges::BOOL },
          disabled: { default: false, range: Ranges::BOOL }
        }.freeze,
        combobox_option_group:         {}.freeze,
        combobox_listbox:              {}.freeze,
        combobox_autocomplete_loading: {}.freeze,
        combobox_autocomplete_empty:   {}.freeze,
        combobox_time:                 {}.freeze
      }.freeze

      FORM = {
        form_group:         {
          layout: { default: :stacked, range: Form::Ranges::LAYOUT },
          error:  { default: false,    range: Ranges::BOOL }
        }.freeze,
        form_label:         {
          required: { default: false, range: Ranges::BOOL },
          hidden:   { default: false, range: Ranges::BOOL }
        }.freeze,
        form_required_mark: {}.freeze,
        form_details:       {}.freeze,
        form_error:         {}.freeze,
        form_input:         { error: { default: false, range: Ranges::BOOL } }.freeze,
        form_textarea:      { error: { default: false, range: Ranges::BOOL } }.freeze,
        form_file:          { error: { default: false, range: Ranges::BOOL } }.freeze,
        form_select:        { error: { default: false, range: Ranges::BOOL } }.freeze,
        form_checkbox:      { error: { default: false, range: Ranges::BOOL } }.freeze,
        form_radio:         { error: { default: false, range: Ranges::BOOL } }.freeze,
        form_input_group:   { error: { default: false, range: Ranges::BOOL } }.freeze,
        form_combobox:      { error: { default: false, range: Ranges::BOOL } }.freeze,
        form_input_reveal:  { error: { default: false, range: Ranges::BOOL } }.freeze,
        form_button_reveal: {}.freeze,
        form_submit:        {
          variant: { default: :default, range: Form::Ranges::SUBMIT_VARIANT }
        }.freeze
      }.freeze

      LAYOUT = {
        divider: {}.freeze,
        popover: {}.freeze
      }.freeze
    end
  end
end
