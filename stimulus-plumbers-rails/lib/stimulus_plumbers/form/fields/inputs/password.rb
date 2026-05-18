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
                             field_theme(:form_input_reveal),
                             field.html_opts,
                             { "data-input-format-target": "input" }
                           )
                           build_input_group(
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
                             field.html_opts
                           )
                           super(attribute, html_opts)
                         end

            render_field(field, input_html)
          end

          private

          def reveal_button
            @template.content_tag(
              :button,
              "",
              type:                       "button",
              class:                      field_theme(:form_button_reveal)[:class],
              "aria-label":               "Show password",
              "aria-pressed":             "false",
              "data-input-format-target": "toggle",
              "data-action":              "click->input-format#toggle"
            )
          end
        end
      end
    end
  end
end
