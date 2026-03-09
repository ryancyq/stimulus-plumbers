# frozen_string_literal: true

require_relative "fields/builder"
require_relative "fields/renderer"
require_relative "fields/password"
require_relative "fields/select"
require_relative "fields/choice"

module StimulusPlumbers
  module Form
    class Builder < ActionView::Helpers::FormBuilder
      include Fields::Password
      include Fields::Select
      include Fields::Choice

      # Options not forwarded to Rails helpers.
      CUSTOM_OPTIONS = %i[label details error required disabled label_visibility layout reveal input_id].freeze

      TEXT_FIELDS = %i[
        text_field email_field url_field telephone_field search_field
        number_field color_field date_field datetime_local_field
        time_field month_field week_field range_field
      ].freeze

      TEXT_FIELDS.each do |method_name|
        define_method(method_name) do |attribute, options = {}|
          custom_opts, rails_opts = extract_options(options)
          field = build_field(attribute, custom_opts)
          apply_aria_describedby!(field, rails_opts)
          apply_theme!(:form_input, rails_opts, error: field.error?)
          render_field(field, super(attribute, rails_opts))
        end
      end

      def text_area(attribute, options = {})
        custom_opts, rails_opts = extract_options(options)
        field = build_field(attribute, custom_opts)
        apply_aria_describedby!(field, rails_opts)
        apply_theme!(:form_textarea, rails_opts, error: field.error?)
        apply_stimulus!(rails_opts, controller: "auto-resize")
        render_field(field, super(attribute, rails_opts))
      end

      def file_field(attribute, options = {})
        custom_opts, rails_opts = extract_options(options)
        field = build_field(attribute, custom_opts)
        apply_aria_describedby!(field, rails_opts)
        apply_theme!(:form_file, rails_opts, error: field.error?)
        render_field(field, super(attribute, rails_opts))
      end

      # Hidden and submit pass through untouched — no group wrapper needed.

      def hidden_field(attribute, options = {})
        super
      end

      def submit(value = nil, options = {})
        super
      end

      private

      # ── Field construction ────────────────────────────────────────────────

      def build_field(attribute, custom_opts)
        Fields::Builder.new(object, attribute).call(custom_opts)
      end

      # ── Field wrapper ─────────────────────────────────────────────────────

      def render_field(field, input_html)
        Fields::Renderer.new(@template, theme, field).call(input_html)
      end

      # ── Helpers ───────────────────────────────────────────────────────────

      def extract_options(options)
        [options.slice(*CUSTOM_OPTIONS), options.except(*CUSTOM_OPTIONS)]
      end

      def apply_theme!(key, options, **variants)
        resolved = theme.resolve(key, **variants).fetch(:classes, "")
        options[:class] = [resolved, options[:class]].compact.join(" ").strip
      end

      def apply_aria_describedby!(field, options)
        options[:id] ||= field.input_id
        ids = []
        ids << field.hint_id  if field.details.present?
        ids << field.error_id if field.error?
        options[:"aria-describedby"] = ids.join(" ") if ids.any?
      end

      def apply_stimulus!(options, controller: nil, action: nil, values: {}, targets: {})
        options[:data] ||= {}
        d = options[:data]

        d[:controller] = [d[:controller], controller].compact.join(" ") if controller

        d[:action] = [d[:action], action].compact.join(" ") if action

        values.each  { |name, val| d[:"#{controller}-#{name}-value"] = val }
        targets.each_key { |name| d[:"#{controller}-target"] = name }
      end

      def theme
        StimulusPlumbers.config.theme
      end
    end
  end
end
