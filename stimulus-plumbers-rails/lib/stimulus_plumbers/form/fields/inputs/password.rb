# frozen_string_literal: true

module StimulusPlumbers
  module Form
    module Fields
      module Inputs
        module Password
          STIMULUS_CONTROLLER = "input-revealable"
          STIMULUS_ACTION     = "click->#{STIMULUS_CONTROLLER}#toggle".freeze
          DEFAULT_AUTOCOMPLETE = "current-password"

          def password_field(attribute, floating: nil, revealable: false, **options)
            html_options = merge_html_options(
              theme.resolve(:form_field_input, floating: floating),
              options,
              { autocomplete: options.delete(:autocomplete) || DEFAULT_AUTOCOMPLETE }
            )
            if revealable
              render_revealable_password(false) do
                super(attribute, merge_html_options(html_options, { data: { input_revealable_target: "input" } }))
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
              kwargs,
              { autocomplete: kwargs.delete(:autocomplete) || DEFAULT_AUTOCOMPLETE }
            )
            if revealable
              render_revealable_password(error, floating: floating) do
                revealable_html_options = merge_html_options(html_options, { data: { input_revealable_target: "input" } })
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
              controller:                           STIMULUS_CONTROLLER,
              input_revealable_reveal_label_value:  I18n.t("stimulus_plumbers.form.password.show", default: "Show password"),
              input_revealable_conceal_label_value: I18n.t("stimulus_plumbers.form.password.hide", default: "Hide password")
            }
          end

          def password_icon(name, target, hidden: false)
            Components::Icon.new(@template).render(
              name,
              size:   :sm,
              aria:   { hidden: "true" },
              data:   { input_revealable_target: target },
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
                  data: { input_revealable_target: "toggle", action: STIMULUS_ACTION }
                }
              )
            ) { @template.capture(&block) }
          end
        end
      end
    end
  end
end
