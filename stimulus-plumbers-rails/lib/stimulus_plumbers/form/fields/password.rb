# frozen_string_literal: true

module StimulusPlumbers
  module Form
    module Fields
      module Password
        def password_field(attribute, options = {})
          custom_opts, rails_opts = extract_options(options)
          reveal = custom_opts.delete(:reveal) { false }
          field  = build_field(attribute, custom_opts)
          apply_aria_describedby!(field, rails_opts)
          apply_theme!(:form_input, rails_opts, error: field.error?)

          input_html = if reveal
                         build_reveal_field(attribute, rails_opts)
                       else
                         super(attribute, rails_opts)
                       end

          render_field(field, input_html)
        end

        private

        def build_reveal_field(attribute, rails_opts)
          rails_opts[:class] = theme.resolve(:form_input_reveal).fetch(:classes, "")
          rails_opts[:data]  = (rails_opts[:data] || {}).merge(
            "password-reveal-target": "input"
          )

          actor_klass = theme.resolve(:form_actor).fetch(:classes, "")
          @template.content_tag(
            :div,
            class: actor_klass,
            data:  { controller: "password-reveal" }
          ) do
            @template.password_field(object_name, attribute, rails_opts) + reveal_button
          end
        end

        def reveal_button
          btn_klass = theme.resolve(:form_button_reveal).fetch(:classes, "")
          @template.content_tag(
            :button,
            "",
            type:         "button",
            class:        btn_klass,
            data:         { action: "click->password-reveal#toggle" },
            "aria-label": "Toggle password visibility"
          )
        end
      end
    end
  end
end
