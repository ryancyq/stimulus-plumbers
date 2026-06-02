# frozen_string_literal: true

module StimulusPlumbers
  module Form
    module Fields
      module Inputs
        module Combobox
          private

          def render_combobox(attribute, input_id:, variant:, opts:, error:, **kwargs, &block)
            panel_id      = Components::Combobox.panel_id_for(input_id)
            combobox_opts = opts.deep_merge(
              input:   { name: field_name(attribute) },
              trigger: { id: input_id }
            )

            Components::Combobox.new(@template).render(
              **combobox_opts,
              haspopup: variant.haspopup,
              popup_id: variant.popup_id_for(panel_id),
              **merge_html_options(theme.resolve(:form_combobox, error: error), kwargs),
              &block
            )
          end
        end
      end
    end
  end
end
