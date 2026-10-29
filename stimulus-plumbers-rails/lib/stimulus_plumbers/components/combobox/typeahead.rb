# frozen_string_literal: true

module StimulusPlumbers
  module Components
    class Combobox
      # Editable combobox: a text input that filters its options, or loads them from `source:` through Turbo.
      class Typeahead < Combobox
        MODE           = "editable"
        VALUE_POLICIES = %i[restricted freeform].freeze
        MATCHES        = %i[prefix contains fuzzy].freeze
        OPTIONS        = %i[value_policy match min_length source param].freeze

        def render(value_policy: nil, match: nil, min_length: nil, source: nil, param: nil, id: nil, **kwargs)
          @value_policy = value_policy && validate_choice!(value_policy, VALUE_POLICIES, :value_policy)
          @match        = match && validate_choice!(match, MATCHES, :match)
          @min_length   = min_length
          @turbo        = turbo(source, param, id)
          super(id: id, **kwargs)
        end

        private

        def turbo(source, param, id)
          raise ArgumentError, "param: needs source:" if param && source.nil?
          return if source.nil?

          raise ArgumentError, "source: needs a nonblank stable id:" if id.to_s.blank?
          raise ArgumentError, "match: filters local options, not source: results" if @match

          Turbo.new(template, source, param)
        end

        def trigger_actions
          ["input->#{STIMULUS_CONTROLLER}#onInput"]
        end

        def trigger_aria
          { autocomplete: "list" }
        end

        def render_host(attrs)
          template.tag.input(type: "text", value: display_label, autocomplete: "off", **attrs)
        end

        # Freeform text has no option.
        def display_label
          label = Options.new(template).label_for(@options, @value)
          label ||= @value if @value_policy == :freeform
          label.to_s
        end

        def editable_data
          {
            "combobox-value-policy-value" => @value_policy&.to_s,
            "combobox-match-value"        => (@turbo ? "none" : @match&.to_s),
            "combobox-min-length-value"   => @min_length&.to_s,
            "combobox-empty-text-value"   => I18n.t("stimulus_plumbers.combobox.typeahead.empty")
          }.compact
        end

        def root_options
          [{ data: editable_data }, ({ data: @turbo.root_data } if @turbo)].compact
        end

        def panel_content(listbox)
          template.safe_join([@turbo ? @turbo.render(@ids[:panel], listbox) : listbox, status])
        end

        def status
          data = { "#{STIMULUS_CONTROLLER}-target" => "status" }
          data.merge!(@turbo.status_data) if @turbo
          template.content_tag(:div, "", **merge_html_options(theme.resolve(:combobox_status), { role: "status", data: data }))
        end
      end
    end
  end
end
