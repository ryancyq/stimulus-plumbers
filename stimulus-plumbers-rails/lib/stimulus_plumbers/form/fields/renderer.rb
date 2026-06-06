# frozen_string_literal: true

module StimulusPlumbers
  module Form
    module Fields
      module Renderer
        FIELD = {
          text:           :render_text_input,
          email:          :render_email_input,
          number:         :render_number_input,
          url:            :render_url_input,
          tel:            :render_tel_input,
          color:          :render_color_input,
          month:          :render_month_input,
          week:           :render_week_input,
          range:          :render_range_input,
          datetime_local: :render_datetime_local_input,
          text_area:      :render_text_area_input,
          file:           :render_file_input,
          password:       :render_password_input,
          date:           :render_combobox_date,
          time:           :render_combobox_time,
          select:         :render_combobox_dropdown,
          search:         :render_combobox_typeahead
        }.freeze

        COLLECTION = {
          collection_select:         :render_collection_combobox_dropdown,
          grouped_collection_select: :render_grouped_collection_combobox_dropdown
        }.freeze

        CHOICE = {
          radio:     :render_collection_radio_button,
          check_box: :render_check_box
        }.freeze
      end
    end
  end
end
