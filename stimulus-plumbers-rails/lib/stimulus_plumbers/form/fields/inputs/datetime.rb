# frozen_string_literal: true

require_relative "combobox"

module StimulusPlumbers
  module Form
    module Fields
      module Inputs
        module Datetime
          include Combobox

          def date_field(attribute, options = {})
            html_options = merge_html_options(theme.resolve(:form_field_input), options)
            super(attribute, html_options)
          end

          def time_field(attribute, options = {})
            html_options = merge_html_options(theme.resolve(:form_field_input), options)
            super(attribute, html_options)
          end

          private

          # Explicit keywords: Ruby 3.0 reports `...` as taking none.
          def render_combobox_date(attribute, html_opts, opts, error, **kwargs)
            render_temporal(attribute, Components::Combobox::Date, html_opts, opts, error, **kwargs)
          end

          def render_combobox_time(attribute, html_opts, opts, error, **kwargs)
            render_temporal(attribute, Components::Combobox::Time, html_opts, opts, error, **kwargs)
          end

          def render_temporal(attribute, component, html_opts, opts, error, floating: nil, **kwargs)
            render_combobox(
              attribute,
              component: component,
              html_opts: html_opts,
              opts:      opts,
              error:     error,
              floating:  floating,
              value:     (object.public_send(attribute) if object.respond_to?(attribute)),
              **kwargs
            )
          end
        end
      end
    end
  end
end
