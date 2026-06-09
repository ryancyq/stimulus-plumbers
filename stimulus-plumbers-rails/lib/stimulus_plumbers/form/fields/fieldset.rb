# frozen_string_literal: true

module StimulusPlumbers
  module Form
    module Fields
      class Fieldset < Plumber::Base
        def render(object, attribute, input_id, field, &block)
          error         = field.error?(object, attribute)
          fieldset_opts = build_fieldset_aria(field, object, attribute, input_id, error)
          Group.new(template).render(layout: :stacked, error: error) do
            template.safe_join(
              [
                build_fieldset(fieldset_opts, field, attribute, error, &block),
                field.render_hint(input_id),
                field.render_errors(object, attribute, input_id)
              ]
            )
          end
        end

        private

        def build_fieldset(fieldset_opts, field, attribute, error, &block)
          template.content_tag(:fieldset, **fieldset_opts) do
            template.safe_join(
              [
                legend(field, attribute),
                fields_wrapper(field.layout) { template.capture(error, &block) }
              ]
            )
          end
        end

        def fields_wrapper(layout, &block)
          html_options = merge_html_options(theme.resolve(:form_field_choice_items, layout: layout))
          template.content_tag(:div, **html_options, &block)
        end

        def legend(field, attribute)
          Label.new(template).render(
            text:     field.label || attribute.to_s.humanize,
            required: field.required,
            hidden:   field.label_hidden?,
            tag:      :legend
          )
        end

        def build_fieldset_aria(field, object, attribute, input_id, error)
          aria = {}
          aria[:describedby] = field.described_by(object, attribute, input_id)
          aria[:invalid]     = "true" if error
          { aria: aria.compact }
        end
      end
    end
  end
end
