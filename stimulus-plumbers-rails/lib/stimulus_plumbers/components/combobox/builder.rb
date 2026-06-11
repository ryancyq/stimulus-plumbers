# frozen_string_literal: true

module StimulusPlumbers
  module Components
    class Combobox
      # Yielded to `Combobox#render`: selects a variant renderer, then exposes its
      # `metadata` (trigger/wrapper wiring) and renders its panel body.
      class Builder < Plumber::Slots
        def dropdown(**options)  = select(Dropdown, options)
        def typeahead(**options) = select(Typeahead, options)
        def date(**options)      = select(Date, options)
        def time(**options)      = select(Time, options)

        def selected? = @slots.key?(:variant)
        def renderer  = selection&.fetch(:renderer)
        def options   = selection ? selection[:options] : {}
        def metadata  = renderer ? renderer::Metadata : DefaultMetadata

        def render_panel(template, panel_attrs:)
          renderer&.new(template)&.render(panel_attrs: panel_attrs, **options)
        end

        # Metadata used when no variant is selected.
        module DefaultMetadata
          module_function

          def haspopup = "dialog"
          def popup_id_for(panel_id) = panel_id
          def trigger_icon = nil
          def trigger_options = {}
          def stimulus_data(_panel_id, _options) = {}
        end

        private

        def select(renderer, options)
          set_slot(:variant, { renderer: renderer, options: options })
          nil
        end

        def selection = resolve(:variant)
      end
    end
  end
end
