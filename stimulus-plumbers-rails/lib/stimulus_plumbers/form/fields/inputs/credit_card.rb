# frozen_string_literal: true

module StimulusPlumbers
  module Form
    module Fields
      module Inputs
        module CreditCard
          STIMULUS_CONTROLLER  = "input-formatter"
          STIMULUS_ACTION      = [
            "input->#{STIMULUS_CONTROLLER}#onInput",
            "beforeinput->#{STIMULUS_CONTROLLER}#onBeforeinput",
            "form:reset->#{STIMULUS_CONTROLLER}#onFormReset"
          ].join(" ").freeze
          DEFAULT_AUTOCOMPLETE = "cc-number"
          DEFAULT_INPUTMODE    = "numeric"

          private

          def render_credit_card_input(attribute, input_attrs, opts, error, groups: nil, separator: nil, **kwargs)
            validate_credit_card_groups!(groups) if groups.present?
            html_options = merge_html_options(
              { autocomplete: DEFAULT_AUTOCOMPLETE, inputmode: DEFAULT_INPUTMODE },
              kwargs,
              credit_card_stimulus_attrs(groups.presence, separator.presence)
            )
            render_text(attribute, input_attrs, opts, error, :text_field, **html_options)
          end

          def credit_card_stimulus_attrs(groups, separator)
            {
              data: {
                controller:                    STIMULUS_CONTROLLER,
                input_formatter_target:        "input",
                input_formatter_format_value:  "creditCard",
                input_formatter_options_value: { groups: groups, separator: separator }.compact,
                action:                        STIMULUS_ACTION
              }
            }
          end

          def validate_credit_card_groups!(groups)
            return if groups.is_a?(Array) && groups.all? { |group| group.is_a?(Integer) && group.positive? }

            raise ArgumentError, "groups must be an array of positive integers"
          end
        end
      end
    end
  end
end
