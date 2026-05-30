# frozen_string_literal: true

require "test_helper"

class PlumberAriaOptionsTest < Minitest::Test
  def instance
    obj = Object.new
    obj.extend(StimulusPlumbers::Plumber::AriaOptions)
    obj
  end

  def test_returns_labelledby_when_provided
    result = instance.labelled_aria("My label", labelledby: "field_label")

    assert_equal "field_label", result[:labelledby]
    assert_nil result[:label]
  end

  def test_returns_label_when_no_labelledby
    result = instance.labelled_aria("My label")

    assert_equal "My label", result[:label]
    assert_nil result[:labelledby]
  end

  def test_returns_empty_when_both_absent
    result = instance.labelled_aria(nil)

    assert_empty result
  end

  def test_label_ignored_when_labelledby_present
    result = instance.labelled_aria("ignored", labelledby: "ref_id")

    assert_equal "ref_id", result[:labelledby]
    refute result.key?(:label)
  end
end
