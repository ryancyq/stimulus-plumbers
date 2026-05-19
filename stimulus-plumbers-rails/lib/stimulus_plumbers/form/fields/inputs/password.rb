# frozen_string_literal: true

module StimulusPlumbers
  module Form
    module Fields
      module Inputs
        module Password
          def password_field(attribute, options = {})
            reveal = options.delete(:reveal) { false }
            Field.new(@template, **options).render(
              object,
              attribute,
              input_id: field_id(attribute)
            ) do |html_opts, opts, error|
              if reveal
                render_reveal_password(merge_html_options(opts, html_opts), error) do |html_options|
                  super(attribute, html_options)
                end
              else
                html_options = merge_html_options(opts, html_opts, field_theme(:form_input, error: error))
                super(attribute, html_options)
              end
            end
          end

          private

          def render_reveal_password(html_opts, error, &block)
            html_options = merge_html_options(
              html_opts,
              field_theme(:form_input, error: error),
              { data: { input_format_target: "input" } }
            )
            render_input_group(
              error:    error,
              trailing: method(:reveal_button),
              **merge_html_options(
                field_theme(:form_input_reveal, error: error),
                { data: { controller: "input-format", input_format_type_value: "password" } }
              )
            ) { @template.capture(html_options, &block) }
          end

          def reveal_button
            html_options = merge_html_options(
              field_theme(:form_button_reveal),
              {
                type: "button",
                aria: { label: "Show password", pressed: "false" },
                data: { input_format_target: "toggle", action: "click->input-format#toggle" }
              }
            )
            @template.content_tag(:button, "", **html_options)
          end
        end
      end
    end
  end
end
