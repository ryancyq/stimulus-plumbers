# frozen_string_literal: true

module StimulusPlumbers
  module Helpers
    module ComboboxHelper
      def sp_combobox_dropdown(...)
        Components::Combobox::Dropdown.new(self).render(...)
      end

      def sp_combobox_typeahead(...)
        Components::Combobox::Typeahead.new(self).render(...)
      end

      def sp_combobox_date(...)
        Components::Combobox::Date.new(self).render(...)
      end

      def sp_combobox_time(...)
        Components::Combobox::Time.new(self).render(...)
      end
    end
  end
end
