# frozen_string_literal: true

module StimulusPlumbers
  module Form
    module Fields
      module Search
        def search_field(attribute, options = {})
          rails_opts, form_field_opts = extract_options(options)
          clearable = form_field_opts.delete(:clearable) { false }
          field     = build_field(attribute, form_field_opts)

          html_opts = merge_html_options(
            rails_opts,
            field_theme(:form_input, error: field.error?),
            field.html_opts
          )
          input_html = if clearable
                         build_input_group(super(attribute, html_opts), field, trailing: clear_button)
                       else
                         super(attribute, html_opts)
                       end

          render_field(field, input_html)
        end

        private

        def clear_button
          @template.content_tag(
            :button,
            "",
            type:         "button",
            class:        field_theme(:form_button_reveal)[:class],
            "aria-label": "Clear search"
          )
        end
      end
    end
  end
end
