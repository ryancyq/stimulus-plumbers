# frozen_string_literal: true

require_relative "password/requirements"

# Top-level so `validates :attr, password_strength: {...}` resolves via Rails' symbol lookup.
class PasswordStrengthValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    requirements = options[:with] || build_requirements
    result = requirements.evaluate(value.to_s)
    return if result[:rules].any? && result[:rules].values.all?

    unmet_messages(requirements, result).each { |message| record.errors.add(attribute, message) }
  end

  private

  def build_requirements
    StimulusPlumbers::Password::Requirements.build do |req|
      req.enforce(**options.except(:with, :message, :on, :if, :unless, :allow_nil, :allow_blank))
    end
  end

  def unmet_messages(requirements, result)
    return [options[:message]] if options[:message]

    labels = requirements.rules
    result[:rules].reject { |_key, ok| ok }.keys.map { |key| labels[key] }
  end
end
