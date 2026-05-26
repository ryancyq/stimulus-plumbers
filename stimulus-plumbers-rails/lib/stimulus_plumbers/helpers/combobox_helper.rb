# frozen_string_literal: true

module StimulusPlumbers
  module Helpers
    module ComboboxHelper
      def sp_combobox_date(**kwargs)
        label = kwargs.delete(:label)
        value = kwargs.delete(:value)
        id    = sp_dom_id
        opts  = Components::Combobox::Date.default_opts.deep_merge(
          input:   { value: value },
          trigger: { id: id, aria: ({ label: label } if label), icon_trailing: "calendar" }.compact
        )
        Components::Combobox.new(self).render(
          **opts,
          data: { input_formatter_format_value: "date" },
          **kwargs
        ) do |popover_id|
          Components::Combobox::Date.new(self).render(value: value, popover_id: popover_id)
        end
      end

      def sp_combobox_dropdown(**kwargs)
        label   = kwargs.delete(:label)
        value   = kwargs.delete(:value)
        options = kwargs.delete(:options) { [] }
        id      = sp_dom_id
        opts    = Components::Combobox::Dropdown.default_opts.deep_merge(
          input:   { value: value },
          trigger: { id: id, aria: ({ label: label } if label), icon_trailing: "chevron-down" }.compact
        )
        Components::Combobox.new(self).render(**opts, **kwargs) do
          Components::Combobox::Dropdown.new(self).render(options: options, value: value, label: label)
        end
      end

      def sp_combobox_typeahead(**kwargs)
        label   = kwargs.delete(:label)
        value   = kwargs.delete(:value)
        options = kwargs.delete(:options) { [] }
        url     = kwargs.delete(:url)
        id      = sp_dom_id
        opts    = Components::Combobox::Typeahead.default_opts.deep_merge(
          input:   { value: value },
          trigger: { id: id, aria: ({ label: label } if label) }.compact,
          popover: { data: url ? { combobox_dropdown_url_value: url } : {} }
        )
        Components::Combobox.new(self).render(
          **opts,
          data: {
            input_combobox_combobox_dropdown_outlet: "##{Components::Combobox.popover_id_for(id)}",
            action:                                  "input->input-combobox#onInput"
          },
          **kwargs
        ) do
          Components::Combobox::Typeahead.new(self).render(options: options, value: value, label: label)
        end
      end

      def sp_combobox_time(**kwargs)
        format = kwargs.delete(:format) { :h12 }
        label  = kwargs.delete(:label)
        step   = kwargs.delete(:step) { 1 }
        value  = kwargs.delete(:value)
        id     = sp_dom_id
        opts   = Components::Combobox::Time.default_opts.deep_merge(
          input:   { value: value },
          trigger: { id: id, aria: ({ label: label } if label), icon_trailing: "clock" }.compact
        )
        Components::Combobox.new(self).render(
          **opts,
          data: { input_formatter_format_value: "time", input_formatter_options_value: { format: format }.to_json },
          **kwargs
        ) do
          Components::Combobox::Time.new(self).render(format: format, step: step, value: value)
        end
      end
    end
  end
end
