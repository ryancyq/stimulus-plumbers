# frozen_string_literal: true

module StimulusPlumbers
  module Components
    class Combobox
      class Typeahead < Plumber::Base
        def self.default_opts
          { trigger: { aria: { autocomplete: "list" }, readonly: false } }
        end

        def self.haspopup = "listbox"

        def self.popup_id(panel_id) = [panel_id, "listbox"].compact.join("_")

        def render(...)
          render_typeahead(...)
        end

        private

        def render_typeahead(panel_attrs: {}, options: [], value: nil, labelledby: nil, label: nil, url: nil)
          template.content_tag(
            :div,
            template.safe_join([listbox(panel_attrs[:id], options, value, labelledby, label), loading, empty]),
            **merge_html_options(
              panel_attrs,
              { data: {
                controller:                  Dropdown::STIMULUS_CONTROLLER,
                action:                      Dropdown::STIMULUS_ACTION,
                combobox_dropdown_url_value: url
              }.compact
}
            )
          )
        end

        def listbox(panel_id, options, value, labelledby, label)
          template.content_tag(
            :ul,
            Options.new(template).render(options, value: value),
            **merge_html_options(
              { classes: theme.resolve(:combobox_listbox).fetch(:classes, "") },
              {
                id:   Typeahead.popup_id(panel_id),
                role: "listbox",
                aria: { label: (label unless labelledby), labelledby: labelledby }.compact,
                data: { "#{Dropdown::STIMULUS_CONTROLLER}_target": "listbox" }
              }
            )
          )
        end

        def loading
          template.content_tag(
            :div,
            **merge_html_options(
              { classes: theme.resolve(:combobox_typeahead_loading).fetch(:classes, "") },
              { hidden: "", aria: { live: "polite" }, data: { "#{Dropdown::STIMULUS_CONTROLLER}_target": "loading" } }
            )
          ) do
            Icon.new(template).render(name: "spinner", classes: "size-(--sp-icon-size) animate-spin")
          end
        end

        def empty
          template.content_tag(
            :div,
            **merge_html_options(
              { classes: theme.resolve(:combobox_typeahead_empty).fetch(:classes, "") },
              { hidden: "", role: "status", data: { "#{Dropdown::STIMULUS_CONTROLLER}_target": "empty" } }
            )
          ) { "No results" }
        end
      end
    end
  end
end
