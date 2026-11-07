# frozen_string_literal: true

module StimulusPlumbers
  module Form
    module Fields
      module Inputs
        module Combobox
          COMBOBOX_OPTIONS = %i[
            options value value_policy match min_length source param close_on_select icon_leading icon_trailing trailing
          ].freeze

          private

          def render_combobox(attribute, component:, input_attrs:, opts:, error:, floating: nil, trigger: {}, **kwargs)
            theme_opts = theme.resolve(:form_field_input_combobox, floating: floating, error: error)
            component.new(@template).render(
              id:         input_attrs[:id],
              name:       field_name(attribute),
              labelledby: Field.label_id(input_attrs[:id]),
              trigger:    merge_html_options({ aria: input_attrs[:aria] }, trigger),
              **kwargs.slice(*COMBOBOX_OPTIONS),
              **merge_html_options(theme_opts, opts, kwargs.except(*COMBOBOX_OPTIONS))
            )
          end
        end
      end
    end
  end
end
