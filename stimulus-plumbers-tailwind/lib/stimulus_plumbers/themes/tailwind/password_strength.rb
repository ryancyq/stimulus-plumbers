# frozen_string_literal: true

module StimulusPlumbers
  module Themes
    module Tailwind
      module PasswordStrength
        private

        def password_strength_wrapper_classes
          { classes: klasses("flex", "flex-col", "gap-(--sp-space-2)") }
        end

        def password_strength_rules_heading_classes
          { classes: klasses("text-(length:--sp-text-sm)", "text-(--sp-color-muted-fg)") }
        end

        def password_strength_rules_classes
          { classes: klasses("flex", "flex-col", "gap-(--sp-space-1)") }
        end

        # State styling keys off data-satisfied (toggled client-side by the controller),
        # not a server-computed flag — the server always renders the initial (unmet) state.
        def password_strength_rule_classes
          state = [
            "text-(--sp-color-muted-fg)",
            "data-[satisfied=true]:text-(--sp-color-success)",
            "data-[satisfied=true]:line-through"
          ]
          { classes: klasses("flex", "items-center", "gap-(--sp-space-1)", *state) }
        end

        def password_strength_rule_icon_classes
          { classes: klasses("size-(--sp-icon-sm)", "shrink-0") }
        end

        def password_strength_level_classes
          { classes: klasses("text-(length:--sp-text-base)", "font-semibold") }
        end
      end
    end
  end
end
