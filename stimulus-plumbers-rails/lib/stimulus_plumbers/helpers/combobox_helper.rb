# frozen_string_literal: true

module StimulusPlumbers
  module Helpers
    module ComboboxHelper
      # Single entry point; panel type chosen by a block method (c.dropdown/date/...).
      def sp_combobox(value: nil, label: nil, id: nil, close_on_select: nil, **kwargs, &block)
        id ||= sp_dom_id
        Components::Combobox.new(self).render(
          trigger:         { id: id, aria: ({ label: label } if label) }.compact,
          input:           { value: value },
          close_on_select: close_on_select,
          **kwargs,
          &block
        )
      end

      def sp_combobox_date(value: nil, label: nil, **kwargs)
        sp_combobox(value: value, label: label, **kwargs) do |c|
          c.date(value: value)
        end
      end

      def sp_combobox_dropdown(options: [], value: nil, label: nil, **kwargs)
        sp_combobox(value: value, label: label, **kwargs) do |c|
          c.dropdown(options: options, value: value, label: label)
        end
      end

      def sp_combobox_typeahead(options: [], value: nil, label: nil, url: nil, **kwargs)
        sp_combobox(value: value, label: label, **kwargs) do |c|
          c.typeahead(options: options, value: value, label: label, url: url)
        end
      end

      def sp_combobox_time(format: :h12, step: 1, value: nil, label: nil, **kwargs)
        sp_combobox(value: value, label: label, **kwargs) do |c|
          c.time(format: format, step: step, value: value)
        end
      end
    end
  end
end
