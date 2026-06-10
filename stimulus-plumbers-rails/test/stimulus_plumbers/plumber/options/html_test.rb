# frozen_string_literal: true

require "test_helper"

class PlumberOptionsHtmlTest < Minitest::Test
  def instance
    Class.new { include StimulusPlumbers::Plumber::Options::Html }.new
  end

  def test_merges_data_attributes
    result = instance.merge_html_options(
      { data: { controller: "ctrl" } },
      { data: { "ctrl-target": "el" } }
    )

    assert_equal "ctrl", result[:data][:controller]
    assert_equal "el",   result[:data][:"ctrl-target"]
  end

  def test_data_keys_merged_from_multiple_hashes
    result = instance.merge_html_options(
      { data: { controller: "ctrl", action: "click->ctrl#act" } },
      { data: { foo: "bar" } }
    )

    assert_equal "ctrl",            result[:data][:controller]
    assert_equal "click->ctrl#act", result[:data][:action]
    assert_equal "bar",             result[:data][:foo]
  end

  def test_preserves_other_top_level_keys
    result = instance.merge_html_options({ id: "foo", aria: { label: "bar" } })

    assert_equal "foo", result[:id]
    assert_equal "bar", result[:aria][:label]
  end

  def test_classes_key_absent_from_result
    result = instance.merge_html_options({ classes: "btn" })

    assert_nil result[:classes]
    assert_equal "btn", result[:class]
  end

  def test_merges_class_and_data_together
    result = instance.merge_html_options(
      { class: "btn", data: { controller: "base" } },
      { class: "active", data: { controller: "extra" } }
    )

    assert_includes result[:class], "btn"
    assert_includes result[:class], "active"
    assert_equal "base extra", result[:data][:controller]
  end

  def test_passthrough_when_no_class_or_data
    result = instance.merge_html_options({ id: "foo" }, { role: "button" })

    assert_nil result[:class]
    assert_nil result[:data]
    assert_equal "foo",    result[:id]
    assert_equal "button", result[:role]
  end
end
