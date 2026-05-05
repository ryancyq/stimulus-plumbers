# frozen_string_literal: true

module StimulusPlumbers
  module Helpers
    module ComboboxHelper
      def sp_combobox_date(label: nil, value: nil, **html_options)
        opts = Components::Combobox::Date.default_opts.deep_merge(
          input:   { value: value },
          popover: { content: Components::Combobox::Date.new(self).render(value: value) }
        )
        opts = opts.deep_merge(trigger: { aria_label: label }) if label
        Components::Combobox::Renderer.new(self).render(
          base_id: sp_dom_id,
          options: opts,
          data:    { input_format_type_value: "date" },
          **html_options
        )
      end

      def sp_combobox_dropdown(label: nil, options: [], value: nil, **html_options)
        opts = Components::Combobox::Dropdown.default_opts.deep_merge(
          input:   { value: value },
          popover: { content: Components::Combobox::Dropdown.new(self).render(options: options, value: value) }
        )
        opts = opts.deep_merge(trigger: { aria_label: label }) if label
        Components::Combobox::Renderer.new(self).render(
          base_id: sp_dom_id,
          options: opts,
          **html_options
        )
      end

      def sp_combobox_autocomplete(label: nil, options: [], value: nil, src: nil, **html_options)
        id         = sp_dom_id
        popover_id = "#{id}_popover"
        opts       = Components::Combobox::Autocomplete.default_opts.deep_merge(
          input:   { value: value },
          popover: {
            content: Components::Combobox::Autocomplete.new(self).render(options: options, value: value, src: src),
            data:    src ? { combobox_dropdown_src_value: src } : {}
          }
        )
        opts = opts.deep_merge(trigger: { aria_label: label }) if label
        Components::Combobox::Renderer.new(self).render(
          base_id: id,
          options: opts,
          data:    {
            input_combobox_combobox_dropdown_outlet: "##{popover_id}",
            action:                                  "input->input-combobox#filter"
          },
          **html_options
        )
      end

      def sp_combobox_time(format: :h12, label: nil, step: 1, value: nil, **html_options)
        opts = Components::Combobox::Time.default_opts.deep_merge(
          input:   { value: value },
          popover: { content: Components::Combobox::Time.new(self).render(format: format, step: step, value: value) }
        )
        opts = opts.deep_merge(trigger: { aria_label: label }) if label
        Components::Combobox::Renderer.new(self).render(
          base_id: sp_dom_id,
          options: opts,
          data:    { input_format_type_value: "time", input_format_options_value: { format: format }.to_json },
          **html_options
        )
      end
    end
  end
end
