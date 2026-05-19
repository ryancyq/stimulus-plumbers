# frozen_string_literal: true

module StimulusPlumbers
  module Form
    module Fields
      class Fieldset < Plumber::Base
        def render(object, attribute, input_id, field, &block)
          error         = field.error?(object, attribute)
          fieldset_opts = build_fieldset_aria(field, object, attribute, input_id, error)
          Group.new(template).render(layout: field.layout, error: error) do
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
                template.capture(error, &block)
              ]
            )
          end
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
          opts = {}
          db = field.described_by(object, attribute, input_id)
          opts[:"aria-describedby"] = db      if db
          opts[:"aria-invalid"]     = "true"  if error
          opts[:"aria-required"]    = "true"  if field.required
          opts
        end
      end
    end
  end
end
