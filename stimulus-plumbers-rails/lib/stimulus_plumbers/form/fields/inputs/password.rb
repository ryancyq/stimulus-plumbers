# frozen_string_literal: true

require_relative "password/revealable"
require_relative "password/strength"

module StimulusPlumbers
  module Form
    module Fields
      module Inputs
        module Password
          include Revealable
          include Strength

          DEFAULT_AUTOCOMPLETE = "current-password"

          def password_field(attribute, floating: nil, revealable: false, **options)
            html_options = merge_html_options(
              theme.resolve(:form_field_input, floating: floating),
              options,
              { autocomplete: options.delete(:autocomplete) || DEFAULT_AUTOCOMPLETE }
            )
            if revealable
              render_revealable_password(false) do
                super(attribute, merge_html_options(html_options, { data: { input_revealable_target: "input" } }))
              end
            else
              super(attribute, html_options)
            end
          end

          # Requirements collected from a `field` block, held for the renderer.
          attr_reader :password_requirements

          private

          def render_password_input(attribute, html_opts, opts, error, floating: nil, revealable: false, **kwargs, &block)
            # A shared `requirements:` object (spec Section C) takes precedence over a field block.
            @password_requirements = kwargs.delete(:requirements) || build_password_requirements(&block)
            input_id = html_opts[:id]
            html_options = password_html_options(html_opts, opts, error, floating, kwargs)
            html_options = apply_strength_wiring(html_options, input_id) if @password_requirements.active?
            input = if revealable
                      render_revealable_password(error, floating: floating) do
                        revealable_html_options = merge_html_options(html_options, { data: { input_revealable_target: "input" } })
                        @template.password_field(@object_name, attribute, objectify_options(revealable_html_options))
                      end
                    else
                      @template.password_field(@object_name, attribute, objectify_options(html_options))
                    end
            return input unless @password_requirements.active?

            wrap_with_strength(input, input_id)
          end

          def build_password_requirements(&block)
            StimulusPlumbers::Password::Requirements.build(&block)
          end

          def password_html_options(html_opts, opts, error, floating, kwargs)
            merge_html_options(
              theme.resolve(:form_field_input, floating: floating, error: error),
              opts,
              html_opts,
              kwargs,
              { autocomplete: kwargs.delete(:autocomplete) || DEFAULT_AUTOCOMPLETE }
            )
          end
        end
      end
    end
  end
end
