# frozen_string_literal: true

module StimulusPlumbers
  module Components
    class Combobox
      # The role=combobox element inside its InputGroup; the block renders the element from its attributes.
      class Trigger < Plumber::Base
        def render(...)
          render_trigger(...)
        end

        private

        def render_trigger(icon_leading: nil, icon_trailing: nil, trailing: nil, **kwargs, &element)
          InputGroup.new(template).render(
            leading:  icon_leading ? -> { render_icon(icon_leading) } : nil,
            trailing: trailing || (icon_trailing ? -> { render_icon(icon_trailing) } : nil),
            **theme.resolve(:combobox_trigger_group)
          ) { element.call(trigger_attrs(**kwargs)) }
        end

        def trigger_attrs(id:, listbox_id:, actions: [], aria: {}, data: {}, **kwargs)
          merge_html_options(
            theme.resolve(:combobox_trigger),
            {
              id:   id,
              role: "combobox",
              aria: { expanded: "false", controls: listbox_id }.merge(aria),
              data: { "#{Combobox::STIMULUS_CONTROLLER}-target" => "trigger" }
            },
            { data: { action: [*actions, "keydown->#{Combobox::STIMULUS_CONTROLLER}#onKeydown"].join(" ") } },
            { data: data },
            kwargs
          )
        end

        def render_icon(name)
          Components::Icon.new(template).render(
            name,
            classes: theme.resolve(:combobox_trigger_icon).fetch(:classes, ""),
            aria:    { hidden: "true" }
          )
        end
      end
    end
  end
end
