# frozen_string_literal: true

require "test_helper"

class PasswordStrengthValidatorTest < ActiveSupport::TestCase
  class Account
    include ActiveModel::Validations

    attr_accessor :password

    def initialize(password)
      @password = password
    end
  end

  def account_class(**options)
    Class.new(Account) { validates :password, password_strength: options }
  end

  def test_valid_password_passes
    klass = account_class(min_length: 4, max_length: 64, digit: true)

    assert_predicate klass.new("abcd1"), :valid?
  end

  def test_unmet_rules_add_errors_by_label
    klass = account_class(min_length: 8, max_length: 64, digit: true)
    account = klass.new("abc")
    account.validate

    assert_includes account.errors[:password], "At least 8 characters"
    assert_includes account.errors[:password], "One number"
  end

  def test_accepts_a_shared_requirements_object
    requirements = StimulusPlumbers::Password::Requirements.build { |r| r.enforce(min_length: 4, max_length: 64) }
    klass = Class.new(Account) { validates :password, password_strength: { with: requirements } }

    assert_predicate klass.new("abcd"), :valid?
    assert_not_predicate klass.new("ab"), :valid?
  end

  def test_custom_message_overrides_labels
    klass = account_class(min_length: 8, max_length: 64, message: "is too weak")
    account = klass.new("abc")
    account.validate

    assert_equal ["is too weak"], account.errors[:password]
  end
end
