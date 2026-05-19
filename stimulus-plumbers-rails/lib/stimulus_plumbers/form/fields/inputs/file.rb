# frozen_string_literal: true

module StimulusPlumbers
  module Form
    module Fields
      module Inputs
        module File
          def file_field(attribute, options = {})
            Field.new(@template, **options).render(
              object,
              attribute,
              input_id: field_id(attribute)
            ) do |html_opts, opts, error|
              html_options = merge_html_options(opts, html_opts, field_theme(:form_file, error: error))
              super(attribute, html_options)
            end
          end
        end
      end
    end
  end
end
