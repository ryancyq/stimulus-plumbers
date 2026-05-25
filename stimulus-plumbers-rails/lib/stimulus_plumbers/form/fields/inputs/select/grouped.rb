# frozen_string_literal: true

module StimulusPlumbers
  module Form
    module Fields
      module Inputs
        module Select
          module Grouped
            def grouped_collection_select(
              attribute,
              collection,
              group_method,
              group_label_method,
              option_key_method,
              option_value_method,
              options = {},
              html_options = {}
            )
              html_native   = options.delete(:html_native) { false }
              icon_leading  = options.delete(:icon_leading)
              icon_trailing = options.delete(:icon_trailing) { "chevron-down" }
              Field.new(@template, **options).render(
                object,
                attribute,
                input_id: field_id(attribute)
              ) do |html_opts, opts, error|
                merged_html_opts = merge_html_options(html_options, html_opts, field_theme(:form_select, error: error))
                if html_native
                  super(
                    attribute,
                    collection,
                    group_method,
                    group_label_method,
                    option_key_method,
                    option_value_method,
                    opts,
                    merged_html_opts
                  )
                else
                  render_select_dropdown(
                    attribute,
                    opts,
                    merged_html_opts,
                    err:           error,
                    icon_leading:  icon_leading,
                    icon_trailing: icon_trailing
                  ) do
                    collection.map do |group|
                      {
                        label:   group.public_send(group_label_method),
                        options: group.public_send(group_method).map do |item|
                          [item.public_send(option_value_method), item.public_send(option_key_method)]
                        end
                      }
                    end
                  end
                end
              end
            end
          end
        end
      end
    end
  end
end
