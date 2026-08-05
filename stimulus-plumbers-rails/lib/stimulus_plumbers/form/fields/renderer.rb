# frozen_string_literal: true

require_relative "../field"

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
          progress:       :render_progress,
          code:           :render_code_input,
          credit_card:    :render_credit_card_input,
          date:           :render_combobox_date,
          time:           :render_combobox_time,
          select:         :render_combobox_dropdown,
          search:         :render_combobox_typeahead
        }.freeze

        # Require every field type to declare its caption association.
        LABEL_MODE = {
          text:           :native,
          email:          :native,
          number:         :native,
          url:            :native,
          tel:            :native,
          color:          :native,
          month:          :native,
          week:           :native,
          range:          :native,
          datetime_local: :native,
          text_area:      :native,
          file:           :native,
          password:       :native,
          progress:       :aria,
          code:           :native,
          credit_card:    :native,
          date:           :native,
          time:           :native,
          select:         :native,
          search:         :native
        }.freeze

        missing = FIELD.keys - LABEL_MODE.keys
        raise ArgumentError, "field types missing a label_mode: #{missing.join(", ")}" if missing.any?

        extra = LABEL_MODE.keys - FIELD.keys
        raise ArgumentError, "label_mode declared for unknown field types: #{extra.join(", ")}" if extra.any?

        LABEL_MODE.each_value { |mode| Field.validate_label_mode!(mode) }

        class << self
          def label_mode(as)
            LABEL_MODE.fetch(as)
          end
        end

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
