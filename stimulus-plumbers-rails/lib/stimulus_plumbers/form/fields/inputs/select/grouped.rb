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
              merged = merge_html_options(html_options, field_theme(:form_select))
              super(
                attribute,
                collection,
                group_method,
                group_label_method,
                option_key_method,
                option_value_method,
                options,
                merged
              )
            end

            private

            def build_grouped_choices(collection, group_label_method, group_method, option_key_method, option_value_method)
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
