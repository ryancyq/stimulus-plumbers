# frozen_string_literal: true

module StimulusPlumbers
  module Components
    class Combobox
      # Yielded to `Combobox#render`: selects a variant renderer, then exposes its
      # `metadata` (trigger/wrapper wiring) and renders its panel body.
      class Builder < Plumber::Slots
        def dropdown(**options)
          select(Dropdown, options)
        end

        def typeahead(**options)
          select(Typeahead, options)
        end

        def date(**options)
          select(Date, options)
        end

        def time(**options)
          select(Time, options)
        end

        def selected?
          @slots.key?(:variant)
        end

        def renderer
          selection&.fetch(:renderer)
        end

        def options
          selection ? selection[:options] : {}
        end

        def metadata
          renderer ? renderer::Metadata : DefaultMetadata
        end

        def render_panel(template, panel_attrs:)
          renderer&.new(template)&.render(panel_attrs: panel_attrs, **options)
        end

        # Metadata used when no variant is selected.
        module DefaultMetadata
          module_function

          def haspopup
            "dialog"
          end

          def popup_id_for(panel_id)
            panel_id
          end

          def trigger_icon
            nil
          end

          def trigger_options
            {}
          end

          def stimulus_data(_panel_id, _options)
            {}
          end
        end

        private

        def select(renderer, options)
          set_slot(:variant, { renderer: renderer, options: options })
          nil
        end

        def selection
          resolve(:variant)
        end
      end
    end
  end
end
