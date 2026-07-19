# frozen_string_literal: true

module StimulusPlumbers
  module Form
    module Fields
      module Inputs
        module Submit
          include Components::Button::IconLayout

          def submit(value = nil, options = {})
            value, options = normalize_submit_arguments(value, options)
            value ||= submit_default_value
            submit_options = extract_submit_options(options)

            validate_submit_accessible_name!(value, options)

            render_submit_button(value, options, **submit_options)
          end

          private

          def normalize_submit_arguments(value, options)
            value.is_a?(Hash) ? [nil, value] : [value, options]
          end

          def extract_submit_options(options)
            {
              type:          options.delete(:type) { :default },
              variant:       options.delete(:variant) { :primary },
              icon_leading:  options.delete(:icon_leading),
              icon_trailing: options.delete(:icon_trailing),
              hide_label:    options.delete(:hide_label) { false }
            }
          end

          def render_submit_button(value, options, type:, variant:, icon_leading:, icon_trailing:, hide_label:)
            Components::Button.new(@template).build(type: type, variant: variant) do |attrs|
              @template.tag.button(
                type: "submit",
                **merge_html_options(attrs, theme.resolve(:form_submit, type: type, variant: variant), options)
              ) { build_layout(submit_slots(icon_leading, icon_trailing)) { submit_label(value, hide_label) } }
            end
          end

          def submit_slots(icon_leading, icon_trailing)
            Components::Button::Slots.new(@template).tap do |slots|
              slots.with_icon_leading(icon_leading) if icon_leading
              slots.with_icon_trailing(icon_trailing) if icon_trailing
            end
          end

          def submit_label(value, hide_label)
            @template.content_tag(
              :span,
              value,
              **merge_html_options(
                theme.resolve(:form_submit_label, hidden: hide_label),
                (hide_label ? { data: { sp_label_hidden: true } } : {})
              )
            )
          end

          def validate_submit_accessible_name!(value, options)
            return if value.present? || options.dig(:aria, :label).present? ||
                      options.dig(:aria, :labelledby).present? || options[:"aria-label"].present?

            raise ArgumentError, "submit button has no accessible name: pass a value or aria: { label: ... }"
          end
        end
      end
    end
  end
end
