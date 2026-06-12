# frozen_string_literal: true

module StimulusPlumbers
  module Helpers
    module ComboboxHelper
      # Single entry point; panel type chosen by a block method (c.dropdown/date/...).
      def sp_combobox(value: nil, label: nil, id: nil, close_on_select: nil, **kwargs, &block)
        Components::Combobox.new(self).render(
          id:              id || sp_dom_id,
          label:           label,
          input:           { value: value },
          close_on_select: close_on_select,
          **kwargs,
          &block
        )
      end

      def sp_combobox_date(value: nil, label: nil, **kwargs)
        sp_combobox(value: value, label: label, **kwargs) do |c|
          panel_opts = { value: value }
          panel_opts[:label] = label if label
          c.date(**panel_opts)
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
          panel_opts = { format: format, step: step, value: value }
          panel_opts[:label] = label if label
          c.time(**panel_opts)
        end
      end
    end
  end
end
