# frozen_string_literal: true

module StimulusPlumbers
  module Form
    module Fields
      module Inputs
        module Password
          def password_field(attribute, floating: nil, revealable: false, **options)
            html_options = merge_html_options(theme.resolve(:form_field_input, floating: floating), options)
            if revealable
              render_revealable_password(false) do
                super(attribute, merge_html_options(html_options, { data: { input_formatter_target: "input" } }))
              end
            else
              super(attribute, html_options)
            end
          end

          private

          def render_password_input(attribute, html_opts, opts, error, floating: nil, revealable: false, **kwargs)
            html_options = merge_html_options(
              theme.resolve(:form_field_input, floating: floating, error: error),
              opts,
              html_opts,
              kwargs
            )
            if revealable
              render_revealable_password(error) do
                revealable_html_options = merge_html_options(html_options, { data: { input_formatter_target: "input" } })
                @template.password_field(@object_name, attribute, objectify_options(revealable_html_options))
              end
            else
              @template.password_field(@object_name, attribute, objectify_options(html_options))
            end
          end

          def render_revealable_password(error, &block)
            render_input_group(
              error:    error,
              trailing: method(:reveal_button),
              **merge_html_options(
                theme.resolve(:form_field_input_reveal, error: error),
                { data: { controller: "input-formatter", input_formatter_format_value: "password" } }
              )
            ) { @template.capture(&block) }
          end

          def reveal_button
            html_options = merge_html_options(
              theme.resolve(:form_field_input_button_reveal),
              {
                type: "button",
                aria: { label: I18n.t("stimulus_plumbers.form.password.show", default: "Show password"), pressed: "false" },
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
