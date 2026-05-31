# frozen_string_literal: true

require_relative "schema/ranges"
require_relative "schema/form/ranges"
require_relative "schema/icon"

module StimulusPlumbers
  module Themes
    module Schema
      ACTION_LIST = {
        action_list:         {}.freeze,
        action_list_item:    {
          active: { default: false, validate: Ranges::BOOL }
        }.freeze,
        action_list_section: {}.freeze
      }.freeze

      AVATAR = {
        avatar: {
          size:  { default: :md, validate: Ranges::SIZE },
          color: { default: nil, validate: :avatar_color_range }
        }.freeze
      }.freeze

      BUTTON = {
        button:       {
          variant: { default: :primary, validate: Ranges::BUTTON_VARIANT },
          size:    { default: :md,      validate: Ranges::SIZE }
        }.freeze,
        button_group: {
          alignment: { default: :left, validate: Ranges::FLEX_ALIGN },
          direction: { default: :row,  validate: Ranges::FLEX_DIRECTION }
        }.freeze,
        button_icon:  {}.freeze
      }.freeze

      CALENDAR = {
        calendar:                      {}.freeze,
        calendar_days_of_week:         {}.freeze,
        calendar_week:                 {}.freeze,
        calendar_days_of_month:        {}.freeze,
        calendar_day:                  {
          today:    { default: false, validate: Ranges::BOOL },
          selected: { default: false, validate: Ranges::BOOL },
          outside:  { default: false, validate: Ranges::BOOL }
        }.freeze,
        calendar_navigation:           {}.freeze,
        calendar_navigation_navigator: {}.freeze
      }.freeze

      CARD = {
        card:         {}.freeze,
        card_section: {}.freeze
      }.freeze

      COMBOBOX = {
        combobox:                   {}.freeze,
        combobox_popover:           {}.freeze,
        combobox_trigger:           {}.freeze,
        combobox_trigger_group:     {}.freeze,
        combobox_option:            {
          selected: { default: false, validate: Ranges::BOOL },
          disabled: { default: false, validate: Ranges::BOOL }
        }.freeze,
        combobox_option_group:      {}.freeze,
        combobox_listbox:           {}.freeze,
        combobox_typeahead_loading: {}.freeze,
        combobox_typeahead_empty:   {}.freeze,
        combobox_time:              {}.freeze
      }.freeze

      FORM = {
        form_group:            {
          layout: { default: :stacked, validate: Form::Ranges::LAYOUT },
          error:  { default: false,    validate: Ranges::BOOL }
        }.freeze,
        form_label:            {
          required: { default: false, validate: Ranges::BOOL },
          hidden:   { default: false, validate: Ranges::BOOL }
        }.freeze,
        form_required_mark:    {}.freeze,
        form_details:          {}.freeze,
        form_error:            {}.freeze,
        form_input:            { error: { default: false, validate: Ranges::BOOL } }.freeze,
        form_textarea:         { error: { default: false, validate: Ranges::BOOL } }.freeze,
        form_file:             { error: { default: false, validate: Ranges::BOOL } }.freeze,
        form_select:           { error: { default: false, validate: Ranges::BOOL } }.freeze,
        form_checkbox:         {
          error:   { default: false, validate: Ranges::BOOL },
          variant: { default: :default, validate: Form::Ranges::CHOICE_VARIANT }
        }.freeze,
        form_radio:            {
          error:   { default: false, validate: Ranges::BOOL },
          variant: { default: :default, validate: Form::Ranges::CHOICE_VARIANT }
        }.freeze,
        form_combobox:         { error: { default: false, validate: Ranges::BOOL } }.freeze,
        form_input_reveal:     { error: { default: false, validate: Ranges::BOOL } }.freeze,
        form_input_clearable:  {}.freeze,
        form_button_reveal:    {}.freeze,
        form_button_clear:     {}.freeze,
        form_checkbox_label:   {
          variant: { default: :default, validate: Form::Ranges::CHOICE_VARIANT }
        }.freeze,
        form_radio_label:      {
          variant: { default: :default, validate: Form::Ranges::CHOICE_VARIANT }
        }.freeze,
        form_choice_items:     {
          layout: { default: :stacked, validate: Form::Ranges::LAYOUT }
        }.freeze,
        form_field:            {
          as: { validate: Form::Ranges::FIELD_TYPE }
        }.freeze,
        form_collection_field: {
          as: { validate: Form::Ranges::COLLECTION_FIELD_TYPE }
        }.freeze,
        form_submit:           {
          variant: { default: :default, validate: Form::Ranges::SUBMIT_VARIANT }
        }.freeze
      }.freeze

      ICON = {
        icon: {}.freeze
      }.freeze

      INPUT_GROUP = {
        input_group: { error: { default: false, validate: Ranges::BOOL } }.freeze
      }.freeze

      LAYOUT = {
        divider:           {}.freeze,
        divider_separator: {}.freeze,
        divider_label:     {}.freeze,
        popover_wrapper:   {}.freeze,
        popover_trigger:   {}.freeze,
        popover:           {}.freeze
      }.freeze
    end
  end
end
