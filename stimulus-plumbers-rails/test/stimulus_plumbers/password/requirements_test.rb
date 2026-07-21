# frozen_string_literal: true

require "test_helper"

class PasswordRequirementsTest < ActiveSupport::TestCase
  Requirements = StimulusPlumbers::Password::Requirements

  def build(&block)
    Requirements.build(&block)
  end

  def test_no_strength_by_default
    req = build

    assert_not req.enforced?
    assert_empty req.rules
  end

  def test_length_requires_both_bounds
    error = assert_raises(ArgumentError) { build { |r| r.enforce(min_length: 8) }.rules }
    assert_match(%r{max_length}, error.message)
  end

  def test_evaluates_length_between_min_and_max
    req = build { |r| r.enforce(min_length: 5, max_length: 12) }

    assert_not req.evaluate("abc")[:rules][:length]
    assert req.evaluate("abcde")[:rules][:length]
    assert_not req.evaluate("a" * 13)[:rules][:length]
  end

  def test_true_enables_a_single_occurrence
    req = build { |r| r.enforce(min_length: 1, max_length: 99, digit: true) }

    assert_not req.evaluate("ab")[:rules][:digit]
    assert req.evaluate("a1")[:rules][:digit]
  end

  def test_integer_sets_minimum_occurrences
    req = build { |r| r.enforce(digit: 2) }

    assert_not req.evaluate("a1")[:rules][:digit]
    assert req.evaluate("a12")[:rules][:digit]
  end

  def test_range_sets_min_and_max_occurrences
    req = build { |r| r.enforce(digit: 1..2) }

    assert req.evaluate("a1")[:rules][:digit]
    assert_not req.evaluate("a123")[:rules][:digit]
  end

  def test_valid_requires_every_rule
    req = build { |r| r.enforce(min_length: 1, max_length: 99, uppercase: true, digit: true) }

    assert_not req.valid?("ab")
    assert req.valid?("aB1")
  end

  def test_valid_is_false_without_rules
    assert_not build.valid?("anything")
  end

  def test_level_is_strong_only_when_all_pass
    req = build { |r| r.enforce(uppercase: true, digit: true) }

    assert_equal "fine", req.evaluate("aB")[:level]
    assert_equal "strong", req.evaluate("aB1")[:level]
  end

  def test_custom_negate_rule_forbids_matches
    req = build do |r|
      r.enforce(min_length: 1, max_length: 99)
      r.rule(:no_spaces, "No spaces", pattern: %r{\s}, negate: true)
    end

    assert_not req.valid?("a b")
    assert req.valid?("abc")
  end

  def test_custom_rule_counts_without_enforce
    req = build { |r| r.rule(:no_spaces, "No spaces", pattern: %r{\s}, negate: true) }

    assert_not req.enforced?
    assert_predicate req, :active?
    assert_equal({ no_spaces: "No spaces" }, req.rules)
    assert req.valid?("abc")
    assert_not req.valid?("a b")
  end

  def test_empty_requirements_are_inactive
    req = build

    assert_not req.active?
    assert_empty req.to_stimulus[:rules]
    assert_equal 0, req.evaluate("anything")[:value]
  end

  def test_rule_rejects_unknown_builtin_without_pattern
    error = assert_raises(ArgumentError) { build.rule(:bogus, "Nope") }
    assert_match(%r{unknown rule key}, error.message)
  end

  def test_to_stimulus_serializes_length_descriptor
    req = build { |r| r.enforce(min_length: 8, max_length: 64) }
    length = req.to_stimulus[:rules].find { |d| d[:key] == "length" }

    assert_equal({ key: "length", label: "At least 8 characters", min: 8, max: 64 }, length)
  end

  def test_to_stimulus_serializes_count_descriptor
    req = build { |r| r.enforce(min_length: 8, max_length: 64, digit: 2) }
    digit = req.to_stimulus[:rules].find { |d| d[:key] == "digit" }

    assert_equal "\\d", digit[:pattern]
    assert_equal 2, digit[:min]
    assert_not digit.key?(:max)
  end

  def test_to_stimulus_carries_low_and_labels
    req = build { |r| r.enforce(min_length: 8, max_length: 64, low: 20) }
    data = req.to_stimulus

    assert_equal({ "low" => 20 }, data[:options])
    assert_equal({ "weak" => "Weak password", "fine" => "Fine password", "strong" => "Strong password" }, data[:labels])
  end
end
