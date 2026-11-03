# frozen_string_literal: true

module StimulusPlumbers
  # Rails 7.1's ActiveModel::Validations::ResolveValue: a Proc, Symbol, or callable resolves against a record.
  module ResolveValue
    def resolve_value(record, value)
      case value
      when Proc   then value.arity.zero? ? value.call : value.call(record)
      when Symbol then record.send(value)
      else value.respond_to?(:call) ? value.call(record) : value
      end
    end
  end
end
