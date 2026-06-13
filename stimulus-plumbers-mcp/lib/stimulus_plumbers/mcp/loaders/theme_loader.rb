# frozen_string_literal: true

module StimulusPlumbers
  module MCP
    class ThemeLoader
      BASE_DOC = <<~MARKDOWN
        # Custom Theme Implementation Guide

        A custom theme is a Ruby class that extends `StimulusPlumbers::Themes::Base` and defines
        `{component_key}_classes(**args)` methods for the components you want to style.

        ## Method Convention

        - **Name:** `{component_key}_classes` — e.g. `button_classes`, `form_group_classes`
        - **Params:** keyword arguments matching the schema params for that component
        - **Return:** a Hash with a `:classes` key containing a space-separated CSS class string

        ```ruby
        def button_classes(type: :default, variant: :default, size: :md)
          { classes: "..." }
        end
        ```

        Components with no params still receive empty kwargs:

        ```ruby
        def form_group_classes
          { classes: "..." }
        end
        ```

        ## Minimal Example

        ```ruby
        class MyTheme < StimulusPlumbers::Themes::Base
          private

          def button_classes(type: :default, variant: :default, size: :md)
            base = "inline-flex items-center gap-2 rounded px-3 py-2"
            variant_class = { primary: "bg-blue-600 text-white", destructive: "bg-red-600 text-white" }.fetch(variant, "bg-gray-100")
            { classes: [base, variant_class].join(" ") }
          end

          def link_classes(type: :default, variant: :default)
            { classes: "underline text-blue-600 hover:text-blue-800" }
          end
        end
        ```

        ## Registration

        ```ruby
        StimulusPlumbers.configure do |config|
          config.theme.register(:my_theme, MyTheme)
          config.theme = :my_theme
        end
        ```

        ## Component Keys

        See `theme://components` for the full list of component keys that can be themed.
        Use `theme://components/{name}` for the method signature and param details per component.

        ## Partial Implementation

        You only need to define methods for components you want to style — unimplemented keys
        return an empty hash, which renders the component with no CSS classes.
      MARKDOWN

      def self.call
        {
          base_doc:   BASE_DOC,
          components: extract_interface
        }
      end

      def self.extract_interface
        Themes::Base::SCHEMA.each_with_object({}) do |(key, params), result|
          result[key] = {
            method:  "#{key}_classes",
            params:  params.transform_values { |meta| format_param(meta) },
            returns: "{ classes: String }"
          }
        end
      end

      def self.format_param(meta)
        valid = meta[:validate]
        entry = { default: meta[:default] }
        entry[:valid] = valid.to_a if valid.respond_to?(:to_a)
        entry
      end

      private_class_method :extract_interface, :format_param
    end
  end
end
