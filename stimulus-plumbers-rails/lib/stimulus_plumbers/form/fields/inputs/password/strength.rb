# frozen_string_literal: true

module StimulusPlumbers
  module Form
    module Fields
      module Inputs
        module Password
          module Strength
            private

            def apply_strength_wiring(html_options, input_id)
              described = [html_options.dig(:aria, :describedby), Components::PasswordStrength.rules_id_for(input_id)]
                          .compact.join(" ")
              merge_html_options(
                html_options,
                aria: { describedby: described },
                data: {
                  password_strength_target: "input", action: "input->password-strength#score"
                }
              )
            end

            def wrap_with_strength(input, input_id)
              Components::PasswordStrength.new(@template).render(input: input, input_id: input_id, config: @password_requirements)
            end
          end
        end
      end
    end
  end
end
