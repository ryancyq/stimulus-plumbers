# frozen_string_literal: true

module StimulusPlumbers
  module Plumber
    class Base
      include HtmlOptions
      include Renderer

      attr_reader :template

      def initialize(template)
        @template = template
      end

      def theme
        StimulusPlumbers.config.theme.current
      end

      # Accessible name for a popup surface: prefer an explicit `aria-labelledby`
      # reference, falling back to an inline `aria-label`. Shared by the combobox
      # listbox/dialog panels so the label-vs-labelledby rule lives in one place.
      def labelled_aria(label, labelledby)
        { label: (label unless labelledby), labelledby: labelledby }.compact
      end
    end
  end
end
