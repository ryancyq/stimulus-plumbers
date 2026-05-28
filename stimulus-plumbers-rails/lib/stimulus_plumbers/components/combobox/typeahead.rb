# frozen_string_literal: true

module StimulusPlumbers
  module Components
    class Combobox
      class Typeahead < Plumber::Base
        def self.default_opts
          Dropdown.default_opts.deep_merge(
            trigger: { aria: { autocomplete: "list" }, readonly: false }
          )
        end

        def render(options: [], value: nil)
          template.safe_join(
            [
              Options.new(template).render(options, value: value),
              loading,
              empty
            ]
          )
        end

        private

        def loading
          template.content_tag(
            :li,
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
            :li,
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
