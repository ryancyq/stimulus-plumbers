# frozen_string_literal: true

module StimulusPlumbers
  module Components
    class Combobox
      # Immutable description of a combobox variant's popup metadata.
      #
      # Replaces the per-class `self.haspopup` / `self.popup_id` / `self.default_opts`
      # methods that used to live on Dropdown/Typeahead/Date/Time. Variants are
      # registered on Combobox (see Combobox.variant) and resolved by name, so callers
      # no longer reference the panel classes or their class methods directly.
      class Variant
        attr_reader :haspopup, :panel_class

        def initialize(haspopup:, panel_class:, default_opts: {}, popup_id_suffix: nil)
          @haspopup        = haspopup
          @panel_class     = panel_class
          @default_opts    = default_opts
          @popup_id_suffix = popup_id_suffix
        end

        def popup_id(panel_id)
          [panel_id, @popup_id_suffix].compact.join("_")
        end

        # Variant defaults under caller overrides (deep_merge: overrides win).
        def opts(**overrides)
          @default_opts.deep_merge(overrides)
        end
      end
    end
  end
end
