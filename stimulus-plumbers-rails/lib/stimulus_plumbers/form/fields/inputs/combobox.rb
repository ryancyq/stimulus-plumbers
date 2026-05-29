# frozen_string_literal: true

module StimulusPlumbers
  module Form
    module Fields
      module Inputs
        module Combobox
          private

          def render_combobox(attribute, input_id:, klass:, opts:, err:, **kwargs, &block)
            panel_id      = Components::Combobox.panel_id_for(input_id)
            combobox_opts = opts.deep_merge(
              input:   { name: field_name(attribute) },
              trigger: { id: input_id }
            )

            Components::Combobox.new(@template).render(
              **combobox_opts,
              haspopup: klass.haspopup,
              popup_id: klass.popup_id(panel_id),
              **merge_html_options(kwargs, field_theme(:form_combobox, error: err)),
              &block
            )
          end
        end
      end
    end
  end
end
