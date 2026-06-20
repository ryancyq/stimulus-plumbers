# frozen_string_literal: true

module StimulusPlumbers
  module Form
    module Fields
      module Inputs
        module Combobox
          private

          def render_combobox(attribute, input_id:, opts:, error:, floating: nil, **kwargs, &block)
            combobox_opts = opts.deep_merge(input: { name: field_name(attribute) })

            Components::Combobox.new(@template).render(
              id: input_id,
              **combobox_opts,
              **merge_html_options(theme.resolve(:form_field_input_combobox, floating: floating, error: error), kwargs),
              &block
            )
          end
        end
      end
    end
  end
end
