# frozen_string_literal: true

module StimulusPlumbers
  module Form
    module Fields
      module Inputs
        module Password
          # Reveal toggle: input group wrapper, toggle button, and its icon pair.
          module Revealable
            STIMULUS_CONTROLLER = "input-revealable"
            STIMULUS_ACTION     = "click->#{STIMULUS_CONTROLLER}#toggle".freeze

            private

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
end
