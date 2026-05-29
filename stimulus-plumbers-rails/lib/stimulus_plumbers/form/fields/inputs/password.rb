# frozen_string_literal: true

module StimulusPlumbers
  module Form
    module Fields
      module Inputs
        module Password
          def password_field(attribute, options = {})
            revealable = options.delete(:revealable) { false }
            html_options = merge_html_options(options, field_theme(:form_input))
            if revealable
              render_revealable_password(false) do
                super(attribute, merge_html_options(html_options, { data: { input_formatter_target: "input" } }))
              end
            else
              super(attribute, html_options)
            end
          end

          private

          def render_password_input(attribute, html_opts, opts, error, revealable: false, **kwargs)
            if revealable
              html_options = merge_html_options(
                opts,
                html_opts,
                kwargs,
                field_theme(:form_input, error: error),
                { data: { input_formatter_target: "input" } }
              )
              render_revealable_password(error) do
                @template.password_field(@object_name, attribute, html_options)
              end
            else
              html_options = merge_html_options(opts, html_opts, kwargs, field_theme(:form_input, error: error))
              @template.password_field(@object_name, attribute, objectify_options(html_options))
            end
          end

          def render_revealable_password(error, &block)
            render_input_group(
              error:    error,
              trailing: method(:reveal_button),
              **merge_html_options(
                field_theme(:form_input_reveal, error: error),
                { data: { controller: "input-formatter", input_formatter_format_value: "password" } }
              )
            ) { @template.capture(&block) }
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
