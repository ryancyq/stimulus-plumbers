# frozen_string_literal: true

module StimulusPlumbers
  module Form
    module Fields
      module Inputs
        module Combobox
          private

          def render_combobox(attribute, input_id:, opts:, err:, **kwargs, &block)
            combobox_opts = opts.deep_merge(
              input:   { name: field_name(attribute) },
              trigger: { id: input_id }
            )

            Components::Combobox.new(@template).render(
              **combobox_opts,
              **merge_html_options(kwargs, field_theme(:form_combobox, error: err)),
              &block
            )
          end
        end
      end
    end
  end
end
