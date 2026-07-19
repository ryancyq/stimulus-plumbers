# frozen_string_literal: true

module StimulusPlumbers
  module Form
    module Fields
      module Inputs
        module Password
          STIMULUS_CONTROLLER = "input-formatter"
          STIMULUS_ACTION     = "click->#{STIMULUS_CONTROLLER}#toggle".freeze

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
              render_revealable_password(error, floating: floating) do
                revealable_html_options = merge_html_options(html_options, { data: { input_formatter_target: "input" } })
                @template.password_field(@object_name, attribute, objectify_options(revealable_html_options))
              end
            else
              @template.password_field(@object_name, attribute, objectify_options(html_options))
            end
          end

          def render_revealable_password(error, floating: nil, &block)
            render_input_group(
              error:    error,
              floating: floating,
              trailing: method(:reveal_button),
              **merge_html_options(
                theme.resolve(:form_field_input_reveal, error: error),
                data: reveal_data
              )
            ) { @template.capture(&block) }
          end

          def reveal_button
            build_reveal_button do
              @template.safe_join(
                [password_icon("reveal", "revealIcon"), password_icon("conceal", "concealIcon", hidden: true)]
              )
            end
          end

          def reveal_data
            {
              controller:                          STIMULUS_CONTROLLER,
              input_formatter_format_value:        "password",
              input_formatter_label_reveal_value:  I18n.t("stimulus_plumbers.form.password.show", default: "Show password"),
              input_formatter_label_conceal_value: I18n.t("stimulus_plumbers.form.password.hide", default: "Hide password")
            }
          end

          def password_icon(name, target, hidden: false)
            Components::Icon.new(@template).render(
              name:   name,
              size:   :sm,
              aria:   { hidden: "true" },
              data:   { input_formatter_target: target },
              hidden: hidden,
              **theme.resolve(:button_icon)
            )
          end

          def build_reveal_button(&block)
            @template.content_tag(
              :button,
              **merge_html_options(
                theme.resolve(:form_field_input_button_reveal),
                {
                  type: "button",
                  aria: { label: I18n.t("stimulus_plumbers.form.password.show", default: "Show password") },
                  data: { input_formatter_target: "toggle", action: STIMULUS_ACTION }
                }
              )
            ) { @template.capture(&block) }
          end
        end
      end
    end
  end
end
