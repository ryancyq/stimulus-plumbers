# frozen_string_literal: true

module StimulusPlumbers
  module Components
    class PasswordStrength < Plumber::Base
      LEVEL_KEYS = %i[weak fine strong].freeze

      class << self
        def rules_id_for(input_id)
          "#{input_id}_rules"
        end
      end

      def render(input:, input_id:, config:)
        @config = config
        @initial = config.evaluate("")
        template.content_tag(:div, **wrapper_options(config)) do
          template.safe_join([input, render_meter, render_level, render_rules_heading, render_rules(input_id)])
        end
      end

      private

      def wrapper_options(config)
        stimulus = config.to_stimulus
        merge_html_options(
          theme.resolve(:password_strength_wrapper),
          data: {
            controller:                      "password-strength",
            password_strength_rules_value:   stimulus[:rules].to_json,
            password_strength_options_value: stimulus[:options].to_json,
            password_strength_labels_value:  stimulus[:labels].to_json
          }
        )
      end

      def render_meter
        ProgressMeter.new(template).render(
          value: @initial[:value], data: { password_strength_target: "meter" }, **@config.thresholds
        )
      end

      def render_level
        template.content_tag(
          :p,
          level_labels[@initial[:level].to_sym],
          **merge_html_options(
            theme.resolve(:password_strength_level),
            data: { password_strength_target: "level" }
          )
        )
      end

      def level_labels
        LEVEL_KEYS.index_with { |key| I18n.t("stimulus_plumbers.password.levels.#{key}") }
      end

      def render_rules_heading
        template.content_tag(
          :p,
          I18n.t("stimulus_plumbers.password.rules_heading"),
          **merge_html_options(theme.resolve(:password_strength_rules_heading))
        )
      end

      def render_rules(input_id)
        html_options = merge_html_options(
          theme.resolve(:password_strength_rules),
          id: self.class.rules_id_for(input_id)
        )
        template.content_tag(:ul, **html_options) do
          template.safe_join(@config.rules.map { |key, label| render_rule(key, label) })
        end
      end

      def render_rule(key, label)
        satisfied = @initial[:rules][key]
        template.content_tag(
          :li,
          **merge_html_options(
            theme.resolve(:password_strength_rule),
            data: {
              password_strength_target: "rule", rule: key, satisfied: satisfied.to_s
            }
          )
        ) do
          template.safe_join(
            [rule_icon("check", "checkIcon", hidden: !satisfied), rule_icon("close", "closeIcon", hidden: satisfied), label]
          )
        end
      end

      def rule_icon(name, target, hidden: false)
        Icon.new(template).render(
          name,
          size:   :sm,
          aria:   { hidden: "true" },
          data:   { password_strength_target: target },
          hidden: hidden,
          **theme.resolve(:password_strength_rule_icon)
        )
      end
    end
  end
end
