# frozen_string_literal: true

module StimulusPlumbers
  module Form
    module Fields
      module Inputs
        module Password
          def password_field(attribute, options = {})
            rails_opts, form_field_opts = extract_options(options)
            reveal = form_field_opts.delete(:reveal) { false }
            field  = build_field(attribute, form_field_opts)

            input_html = if reveal
                           input_opts = merge_html_options(
                             rails_opts,
                             field_theme(:form_input_reveal, error: field.error?),
                             field.html_options,
                             { "data-input-format-target": "input" }
                           )
                           render_input_group(
                             super(attribute, input_opts),
                             field,
                             trailing:                       reveal_button,
                             "data-controller":              "input-format",
                             "data-input-format-type-value": "password"
                           )
                         else
                           html_opts = merge_html_options(
                             rails_opts,
                             field_theme(:form_input, error: field.error?),
                             field.html_options
                           )
                           super(attribute, html_opts)
                         end

            render_field(field, input_html)
          end

          private

          def reveal_button
            html_options = merge_html_options(
              field_theme(:form_button_reveal),
              {
                type:                       "button",
                "aria-label":               "Show password",
                "aria-pressed":             "false",
                "data-input-format-target": "toggle",
                "data-action":              "click->input-format#toggle"
              }
            )
            @template.content_tag(:button, "", **html_options)
          end
        end
      end
    end
  end
end
