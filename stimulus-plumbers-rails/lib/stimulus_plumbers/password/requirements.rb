# frozen_string_literal: true

module StimulusPlumbers
  module Password
    # Declarative password rule set: DSL + evaluation + serialization. Consumed by
    # the form renderer, PasswordStrengthValidator, and the JS controller (via to_stimulus).
    class Requirements
      LEVEL_KEYS = %i[weak fine strong].freeze
      BUILTIN_KEYS = %i[length uppercase lowercase digit symbol].freeze
      DEFAULT_THRESHOLDS = { low: 34, high: 100, optimum: 100 }.freeze

      BUILTIN_PATTERNS = {
        uppercase: "[A-Z]",
        lowercase: "[a-z]",
        digit:     "\\d",
        symbol:    "[^A-Za-z0-9]"
      }.freeze

      class << self
        def build
          new.tap { |req| yield req if block_given? }
        end
      end

      def initialize
        @enforced_options = nil
        @custom = {}
        @overrides = {}
      end

      def enforce(**options)
        @enforced_options = options
        nil
      end

      def rule(key, label = nil, pattern: nil, min: nil, max: nil, negate: false)
        key = key.to_sym
        if pattern
          if negate
            min = 0
            max = 0
          end
          @custom[key] = { pattern: source_of(pattern), min: min.nil? ? 1 : min, max: max, label: label }
        else
          raise ArgumentError, unknown_rule_message(key) unless BUILTIN_KEYS.include?(key)

          @overrides[key] = label
        end
        nil
      end

      def enforced?
        !@enforced_options.nil?
      end

      # Any rule present — built-ins (only when enforced?) or a custom rule. Drives whether
      # the form renders the strength UI; enforced? alone misses custom-only rule sets.
      def active?
        descriptors.any?
      end

      def rules
        descriptors.to_h { |descriptor| [descriptor[:key], descriptor[:label]] }
      end

      def thresholds
        DEFAULT_THRESHOLDS.merge((@enforced_options || {}).slice(*DEFAULT_THRESHOLDS.keys))
      end

      def evaluate(password)
        password = password.to_s
        results = descriptors.to_h { |descriptor| [descriptor[:key], satisfies?(descriptor, password)] }
        satisfied = results.values.count(true)
        { rules: results, value: score(satisfied, results.size), level: level_for(satisfied, results.size) }
      end

      def valid?(password)
        result = evaluate(password)
        result[:rules].any? && result[:rules].values.all?
      end

      def to_stimulus
        { rules: descriptors.map { |descriptor| serialize(descriptor) }, options: stimulus_options, labels: level_labels }
      end

      private

      def descriptors
        list = enforced? ? BUILTIN_KEYS.filter_map { |key| builtin_descriptor(key) } : []
        @custom.each do |key, spec|
          list << { key: key, pattern: spec[:pattern], min: spec[:min], max: spec[:max], label: spec[:label] }
        end
        apply_overrides(list)
      end

      def builtin_descriptor(key)
        options = @enforced_options
        return length_descriptor(options) if key == :length && (options.key?(:min_length) || options.key?(:max_length))

        bounds = parse_count(options[key])
        return unless bounds

        label = builtin_label(key, bounds[:min])
        { key: key, pattern: BUILTIN_PATTERNS[key], min: bounds[:min], max: bounds[:max], label: label }
      end

      def length_descriptor(options)
        unless options.key?(:min_length) && options.key?(:max_length)
          raise ArgumentError, "length rule requires both min_length and max_length"
        end

        label = builtin_label(:length, options[:min_length])
        { key: :length, min: options[:min_length], max: options[:max_length], label: label }
      end

      def parse_count(value)
        case value
        when nil, false then nil
        when true then { min: 1, max: nil }
        when Integer then { min: value, max: nil }
        when Range then { min: value.begin, max: value.end }
        else raise ArgumentError, "invalid occurrence count #{value.inspect}"
        end
      end

      def satisfies?(descriptor, password)
        n = descriptor[:pattern] ? password.scan(Regexp.new(descriptor[:pattern])).size : password.length
        min = descriptor[:min] || 0
        max = descriptor[:max] || Float::INFINITY
        n.between?(min, max)
      end

      def score(satisfied, total)
        total.zero? ? 0 : (satisfied.to_f / total * 100).round
      end

      def level_for(satisfied, total)
        return "strong" if total.positive? && satisfied == total

        score(satisfied, total) < thresholds[:low] ? "weak" : "fine"
      end

      def serialize(descriptor)
        data = { key: descriptor[:key].to_s, label: descriptor[:label], min: descriptor[:min] }
        data[:max] = descriptor[:max] unless descriptor[:max].nil?
        data[:pattern] = descriptor[:pattern] if descriptor[:pattern]
        data
      end

      def stimulus_options
        { "low" => thresholds[:low] }
      end

      def level_labels
        LEVEL_KEYS.index_with { |key| I18n.t("stimulus_plumbers.password.levels.#{key}") }.transform_keys(&:to_s)
      end

      def apply_overrides(list)
        return list if @overrides.empty?

        list.map do |descriptor|
          next descriptor unless @overrides.key?(descriptor[:key])

          descriptor.merge(label: @overrides[descriptor[:key]])
        end
      end

      def builtin_label(key, count)
        I18n.t("stimulus_plumbers.password.rules.#{key}", count: count)
      end

      def source_of(pattern)
        pattern.is_a?(Regexp) ? pattern.source : pattern.to_s
      end

      def unknown_rule_message(key)
        known = BUILTIN_KEYS.map(&:inspect).join(", ")
        "unknown rule key: #{key.inspect} (known keys: #{known}), or pass pattern: for a custom rule"
      end
    end
  end
end
