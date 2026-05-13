# frozen_string_literal: true

module StimulusPlumbers
  module Components
    class Combobox
      class Autocomplete < Plumber::Base
        def self.default_opts
          Dropdown.default_opts.deep_merge(
            trigger: { aria_autocomplete: "list", readonly: false }
          )
        end

        def render(options: [], value: nil, label: nil, **_kwargs)
          template.safe_join([listbox(options, value, label), loading, empty])
        end

        private

        def listbox(options, value, label)
          attrs = merge_html_options(
            { classes: theme.resolve(:combobox_listbox).fetch(:classes, "") },
            { role: "listbox", data: { "#{Dropdown::STIMULUS_CONTROLLER}_target": "listbox" } }
          )
          attrs[:aria] = { label: label } if label

          template.content_tag(:ul, **attrs) do
            Options.new(template).render(options, value: value)
          end
        end

        def loading
          template.content_tag(
            :div,
            **merge_html_options(
              { classes: theme.resolve(:combobox_autocomplete_loading).fetch(:classes, "") },
              { hidden: "", aria: { live: "polite" }, data: { "#{Dropdown::STIMULUS_CONTROLLER}_target": "loading" } }
            )
          ) { "" }
        end

        def empty
          template.content_tag(
            :div,
            **merge_html_options(
              { classes: theme.resolve(:combobox_autocomplete_empty).fetch(:classes, "") },
              { hidden: "", role: "status", data: { "#{Dropdown::STIMULUS_CONTROLLER}_target": "empty" } }
            )
          ) { "No results" }
        end
      end
    end
  end
end
