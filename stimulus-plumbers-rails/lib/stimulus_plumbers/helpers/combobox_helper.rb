# frozen_string_literal: true

module StimulusPlumbers
  module Helpers
    module ComboboxHelper
      def sp_combobox_date(**html_options)
        label = html_options.delete(:label)
        value = html_options.delete(:value)
        id    = sp_dom_id
        opts  = Components::Combobox::Date.default_opts.deep_merge(
          input:   { value: value },
          trigger: { id: id, aria_label: label }.compact
        )
        Components::Combobox.new(self).render(
          **opts,
          data: { input_formatter_format_value: "date" },
          **html_options
        ) do |popover_id|
          Components::Combobox::Date.new(self).render(value: value, popover_id: popover_id)
        end
      end

      def sp_combobox_dropdown(**html_options)
        label   = html_options.delete(:label)
        value   = html_options.delete(:value)
        options = html_options.delete(:options) { [] }
        id      = sp_dom_id
        opts    = Components::Combobox::Dropdown.default_opts.deep_merge(
          input:   { value: value },
          trigger: { id: id, aria_label: label }.compact
        )
        Components::Combobox.new(self).render(**opts, **html_options) do
          Components::Combobox::Dropdown.new(self).render(options: options, value: value, label: label)
        end
      end

      def sp_combobox_typeahead(**html_options)
        label   = html_options.delete(:label)
        value   = html_options.delete(:value)
        options = html_options.delete(:options) { [] }
        url     = html_options.delete(:url)
        id      = sp_dom_id
        opts    = Components::Combobox::Typeahead.default_opts.deep_merge(
          input:   { value: value },
          trigger: { id: id, aria_label: label }.compact,
          popover: { data: url ? { combobox_dropdown_url_value: url } : {} }
        )
        Components::Combobox.new(self).render(
          **opts,
          data: {
            input_combobox_combobox_dropdown_outlet: "##{Components::Combobox.popover_id_for(id)}",
            action:                                  "input->input-combobox#onInput"
          },
          **html_options
        ) do
          Components::Combobox::Typeahead.new(self).render(options: options, value: value, label: label)
        end
      end

      def sp_combobox_time(**html_options)
        format = html_options.delete(:format) { :h12 }
        label  = html_options.delete(:label)
        step   = html_options.delete(:step) { 1 }
        value  = html_options.delete(:value)
        id     = sp_dom_id
        opts   = Components::Combobox::Time.default_opts.deep_merge(
          input:   { value: value },
          trigger: { id: id, aria_label: label }.compact
        )
        Components::Combobox.new(self).render(
          **opts,
          data: { input_formatter_format_value: "time", input_formatter_options_value: { format: format }.to_json },
          **html_options
        ) do
          Components::Combobox::Time.new(self).render(format: format, step: step, value: value)
        end
      end
    end
  end
end
