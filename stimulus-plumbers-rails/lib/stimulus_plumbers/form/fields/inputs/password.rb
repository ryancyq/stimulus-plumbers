# frozen_string_literal: true

module StimulusPlumbers
  module Form
    module Fields
      module Inputs
        module Password
          def password_field(attribute, options = {})
            reveal = options.delete(:reveal) { false }
            merged = merge_html_options(options, field_theme(:form_input))
            if reveal
              render_reveal_password(merged, false) { |html_options| super(attribute, html_options) }
            else
              super(attribute, merged)
            end
          end

          private

          def render_password_input(attribute, html_opts, opts, error, reveal: false, **_)
            merged = merge_html_options(opts, html_opts)
            if reveal
              render_reveal_password(merged, error) do |html_options|
                @template.password_field(@object_name, attribute, html_options)
              end
            else
              html_options = merge_html_options(merged, field_theme(:form_input, error: error))
              @template.password_field(@object_name, attribute, objectify_options(html_options))
            end
          end

          def render_reveal_password(html_opts, error, &block)
            html_options = merge_html_options(
              html_opts,
              field_theme(:form_input, error: error),
              { data: { input_formatter_target: "input" } }
            )
            render_input_group(
              error:    error,
              trailing: method(:reveal_button),
              **merge_html_options(
                field_theme(:form_input_reveal, error: error),
                { data: { controller: "input-formatter", input_formatter_format_value: "password" } }
              )
            ) { @template.capture(html_options, &block) }
          end

          def reveal_button
            html_options = merge_html_options(
              field_theme(:form_button_reveal),
              {
                type: "button",
                aria: { label: "Show password", pressed: "false" },
                data: { input_formatter_target: "toggle", action: "click->input-formatter#toggle" }
              }
            )
            @template.content_tag(:button, "", **html_options)
          end
        end
      end
    end
  end
end
