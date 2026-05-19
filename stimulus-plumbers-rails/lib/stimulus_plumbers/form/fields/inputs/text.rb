# frozen_string_literal: true

module StimulusPlumbers
  module Form
    module Fields
      module Inputs
        module Text
          FIELD_TYPES = %i[
            color_field
            datetime_local_field
            email_field
            month_field
            number_field
            range_field
            telephone_field
            text_field
            url_field
            week_field
          ].freeze

          FIELD_TYPES.each do |method_name|
            define_method(method_name) do |attribute, options = {}|
              Field.new(@template, **options).render(
                object,
                attribute,
                input_id: field_id(attribute)
              ) do |html_opts, opts, error|
                html_options = merge_html_options(opts, html_opts, field_theme(:form_input, error: error))
                super(attribute, html_options)
              end
            end
          end
        end
      end
    end
  end
end
