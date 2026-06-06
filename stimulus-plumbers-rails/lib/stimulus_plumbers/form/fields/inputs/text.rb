# frozen_string_literal: true

module StimulusPlumbers
  module Form
    module Fields
      module Inputs
        module Text
          TEXT_FIELD_METHODS = {
            text:           :text_field,
            email:          :email_field,
            number:         :number_field,
            url:            :url_field,
            tel:            :telephone_field,
            color:          :color_field,
            month:          :month_field,
            week:           :week_field,
            range:          :range_field,
            datetime_local: :datetime_local_field
          }.freeze

          TEXT_FIELD_METHODS.each_value do |template_method|
            define_method(template_method) do |attribute, options = {}|
              html_options = merge_html_options(theme.resolve(:form_field_input), options)
              super(attribute, html_options)
            end
          end

          private

          TEXT_FIELD_METHODS.each do |as_key, template_method|
            define_method(:"render_#{as_key}_input") do |attribute, html_opts, opts, error, **kwargs|
              render_text(attribute, html_opts, opts, error, template_method, **kwargs)
            end
          end

          def render_text(attribute, html_opts, opts, error, template_method, **kwargs)
            html_options = merge_html_options(theme.resolve(:form_field_input, error: error), opts, html_opts, kwargs)
            @template.public_send(template_method, @object_name, attribute, objectify_options(html_options))
          end
        end
      end
    end
  end
end
