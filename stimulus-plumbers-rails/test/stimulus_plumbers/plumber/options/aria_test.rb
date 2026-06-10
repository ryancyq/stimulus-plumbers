# frozen_string_literal: true

require "test_helper"

class PlumberOptionsAriaTest < Minitest::Test
  def instance
    obj = Object.new
    obj.extend(StimulusPlumbers::Plumber::Options::Aria)
    obj
  end

  def test_returns_labelledby_when_provided
    result = instance.labelled_aria("My label", labelledby: "field_label")

    assert_equal "field_label", result[:labelledby]
    refute result.key?(:label)
  end

  def test_returns_label_when_no_labelledby
    result = instance.labelled_aria("My label")

    assert_equal "My label", result[:label]
    assert_nil result[:labelledby]
  end

  def test_returns_empty_hash_when_label_is_nil
    result = instance.labelled_aria(nil)

    assert_empty result
  end
end
