# frozen_string_literal: true

require_relative "../form/field"
require_relative "schema/ranges"
require_relative "schema/avatar/ranges"
require_relative "schema/button/ranges"
require_relative "schema/card/ranges"
require_relative "schema/indicator/ranges"
require_relative "schema/link/ranges"
require_relative "schema/form/ranges"
require_relative "schema/form/checkbox/ranges"
require_relative "schema/form/floating/ranges"
require_relative "schema/form/radio/ranges"
require_relative "schema/icon"

module StimulusPlumbers
  module Themes
    module Schema
      LIST = {
        list:                     {}.freeze,
        list_section:             {}.freeze,
        list_section_title:       {}.freeze,
        list_section_description: {}.freeze,
        list_item:                {}.freeze,
        list_item_icon:           {}.freeze,
        list_item_content:        {}.freeze,
        list_item_title:          {}.freeze,
        list_item_description:    {}.freeze
      }.freeze

      ORDERED_LIST = {
        ordered_list:                  {}.freeze,
        ordered_list_item:             {}.freeze,
        ordered_list_item_handle:      {}.freeze,
        ordered_list_item_content:     {}.freeze,
        ordered_list_item_title:       {}.freeze,
        ordered_list_item_description: {}.freeze
      }.freeze

      AVATAR = {
        avatar:       {
          size:    { default: :md, validate: Avatar::Ranges::SIZE },
          variant: { default: nil, validate: :avatar_variant_range }
        }.freeze,
        avatar_image: {}.freeze
      }.freeze

      BUTTON = {
        button:       {
          type:    { default: :default, validate: Button::Ranges::TYPE },
          variant: { default: :primary, validate: Button::Ranges::VARIANT },
          size:    { default: :md,      validate: Button::Ranges::SIZE }
        }.freeze,
        button_group: {
          layout: { default: :inline, validate: Button::Ranges::LAYOUT }
        }.freeze,
        button_icon:  {}.freeze
      }.freeze

      CALENDAR = {
        calendar:                 {}.freeze,
        calendar_days_of_week:    {}.freeze,
        calendar_days_of_month:   {}.freeze,
        calendar_months_of_year:  {}.freeze,
        calendar_years_of_decade: {}.freeze,
        calendar_row:             {}.freeze,
        calendar_day:             {
          today:    { default: false, validate: Ranges::BOOL },
          selected: { default: false, validate: Ranges::BOOL },
          outside:  { default: false, validate: Ranges::BOOL }
        }.freeze,
        calendar_month:           {
          outside: { default: false, validate: Ranges::BOOL }
        }.freeze,
        calendar_year:            {
          outside: { default: false, validate: Ranges::BOOL }
        }.freeze,
        calendar_quarter_grid:    {}.freeze
      }.freeze

      CARD = {
        card:        { variant: { default: :tertiary, validate: Card::Ranges::VARIANT } }.freeze,
        card_header: {}.freeze,
        card_icon:   {}.freeze,
        card_title:  {}.freeze,
        card_body:   {}.freeze,
        card_action: {}.freeze
      }.freeze

      COMBOBOX = {
        combobox:                           {}.freeze,
        combobox_popover:                   {}.freeze,
        combobox_trigger:                   {}.freeze,
        combobox_trigger_icon:              {}.freeze,
        combobox_trigger_group:             {}.freeze,
        combobox_option:                    {
          selected: { default: false, validate: Ranges::BOOL },
          disabled: { default: false, validate: Ranges::BOOL }
        }.freeze,
        combobox_option_group:              {}.freeze,
        combobox_listbox:                   {}.freeze,
        combobox_typeahead_loading:         {}.freeze,
        combobox_typeahead_loading_icon:    {}.freeze,
        combobox_typeahead_empty:           {}.freeze,
        combobox_time:                      {}.freeze,
        combobox_time_drum:                 { type: { default: :unit, validate: %i[unit period] } }.freeze,
        combobox_date_navigation:           {}.freeze,
        combobox_date_navigation_navigator: {}.freeze,
        combobox_date_navigation_title:     {}.freeze
      }.freeze

      FORM = {
        form_group:                     {
          layout: { default: :stacked, validate: Form::Ranges::LAYOUT },
          error:  { default: false,    validate: Ranges::BOOL }
        }.freeze,
        form_field_label:               {
          required: { default: false, validate: Ranges::BOOL },
          hidden:   { default: false, validate: Ranges::BOOL },
          floating: { default: nil,   validate: [nil, *Form::Floating::Ranges::TYPE] },
          error:    { default: false, validate: Ranges::BOOL }
        }.freeze,
        form_field_required_mark:       {}.freeze,
        form_field_hint:                {}.freeze,
        form_field_error:               {}.freeze,
        form_field_choice_items:        {
          layout: { default: :stacked, validate: Form::Ranges::LAYOUT }
        }.freeze,
        form_field_checkbox_label:      {
          type:    { default: :default,  validate: Form::Checkbox::Ranges::TYPE },
          variant: { default: :tertiary, validate: Form::Checkbox::Ranges::VARIANT }
        }.freeze,
        form_field_radio_label:         {
          type:    { default: :default,  validate: Form::Radio::Ranges::TYPE },
          variant: { default: :tertiary, validate: Form::Radio::Ranges::VARIANT }
        }.freeze,
        form_field_radio_item_group:    {}.freeze,
        form_field_input:               {
          error:    { default: false, validate: Ranges::BOOL },
          floating: { default: nil,   validate: [nil, *Form::Floating::Ranges::TYPE] }
        }.freeze,
        form_field_input_group:         {
          floating: { default: nil, validate: [nil, *Form::Floating::Ranges::TYPE] }
        }.freeze,
        form_field_input_textarea:      {
          error:    { default: false, validate: Ranges::BOOL },
          floating: { default: nil,   validate: [nil, *Form::Floating::Ranges::TYPE] }
        }.freeze,
        form_field_input_file:          {
          error:    { default: false, validate: Ranges::BOOL },
          floating: { default: nil,   validate: [nil, *Form::Floating::Ranges::TYPE] }
        }.freeze,
        form_field_input_select:        {
          error:    { default: false, validate: Ranges::BOOL },
          floating: { default: nil,   validate: [nil, *Form::Floating::Ranges::TYPE] }
        }.freeze,
        form_field_input_checkbox:      {
          error:   { default: false,     validate: Ranges::BOOL },
          type:    { default: :default,  validate: Form::Checkbox::Ranges::TYPE },
          variant: { default: :tertiary, validate: Form::Checkbox::Ranges::VARIANT }
        }.freeze,
        form_field_input_radio:         {
          error:   { default: false,     validate: Ranges::BOOL },
          type:    { default: :default,  validate: Form::Radio::Ranges::TYPE },
          variant: { default: :tertiary, validate: Form::Radio::Ranges::VARIANT }
        }.freeze,
        form_field_input_combobox:      {
          error:    { default: false, validate: Ranges::BOOL },
          floating: { default: nil,   validate: [nil, *Form::Floating::Ranges::TYPE] }
        }.freeze,
        form_field_input_reveal:        { error: { default: false, validate: Ranges::BOOL } }.freeze,
        form_field_input_clearable:     {}.freeze,
        form_field_input_button_reveal: {}.freeze,
        form_field_input_button_clear:  {}.freeze,
        form_submit:                    {
          type:    { default: :default, validate: Button::Ranges::TYPE },
          variant: { default: :primary, validate: Button::Ranges::VARIANT }
        }.freeze
      }.freeze

      ICON = {
        icon: { size: { default: :lg, validate: %i[sm md lg] } }.freeze
      }.freeze

      INDICATOR = {
        indicator:         {
          type:    { default: :dot,     validate: Indicator::Ranges::TYPE },
          variant: { default: :primary, validate: Indicator::Ranges::VARIANT }
        }.freeze,
        indicator_wrapper: {}.freeze,
        indicator_pulse:   {}.freeze
      }.freeze

      INPUT_GROUP = {
        input_group: {
          error:    { default: false, validate: Ranges::BOOL },
          floating: { default: nil,   validate: [nil, *Form::Floating::Ranges::TYPE] }
        }.freeze
      }.freeze

      LINK = {
        link:      {
          type:    { default: :default, validate: Link::Ranges::TYPE },
          variant: { default: :default, validate: Link::Ranges::VARIANT }
        }.freeze,
        link_icon: {}.freeze
      }.freeze

      LAYOUT = {
        divider:           {}.freeze,
        divider_separator: {}.freeze,
        divider_label:     {}.freeze,
        popover_wrapper:   {}.freeze,
        popover_trigger:   {}.freeze,
        popover:           {}.freeze
      }.freeze

      PROGRESS = {
        progress_bar:      {}.freeze,
        progress_bar_fill: {}.freeze,
        progress_ring:     {}.freeze,
        progress_meter:    {}.freeze
      }.freeze

      TIMELINE = {
        timeline:                          {
          orientation: { default: :vertical, validate: %i[vertical horizontal] }
        }.freeze,
        timeline_item:                     {
          orientation: { default: :vertical, validate: %i[vertical horizontal] }
        }.freeze,
        timeline_item_indicator:           {
          type:        { default: :dot,      validate: %i[dot icon] },
          orientation: { default: :vertical, validate: %i[vertical horizontal] }
        }.freeze,
        timeline_item_time:                {
          type: { default: :default, validate: %i[default badge] }
        }.freeze,
        timeline_item_title:               {}.freeze,
        timeline_item_heading:             {}.freeze,
        timeline_item_trigger:             {}.freeze,
        timeline_item_description:         {}.freeze,
        timeline_item_detail:              {}.freeze,
        timeline_item_actions:             {}.freeze,
        timeline_item_connector:           {}.freeze,
        timeline_item_content:             {}.freeze,
        timeline_track_line:               {}.freeze,
        timeline_item_indicator_icon_slot: {}.freeze,
        timeline_group:                    {}.freeze,
        timeline_group_section:            {}.freeze,
        timeline_group_section_date:       {}.freeze,
        timeline_group_section_list:       {}.freeze
      }.freeze
    end
  end
end
