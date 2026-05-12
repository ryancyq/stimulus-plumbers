# frozen_string_literal: true

require "test_helper"

class PlumberHtmlOptionsTest < Minitest::Test
  def instance
    obj = Object.new
    obj.extend(StimulusPlumbers::Plumber::HtmlOptions)
    obj
  end

  def test_merges_data_attributes
    result = instance.merge_html_options(
      { data: { controller: "ctrl" } },
      { data: { "ctrl-target": "el" } }
    )

    assert_equal "ctrl", result[:data][:controller]
    assert_equal "el",   result[:data][:"ctrl-target"]
  end

  def test_merge_preserves_all_nested_data_keys
    result = instance.merge_html_options(
      { data: { controller: "ctrl", action: "click->ctrl#act" } },
      { data: { foo: "bar" } }
    )

    assert_equal "ctrl",            result[:data][:controller]
    assert_equal "click->ctrl#act", result[:data][:action]
    assert_equal "bar",             result[:data][:foo]
  end

  def test_space_joins_controller_across_data_hashes
    result = instance.merge_html_options(
      { data: { controller: "base-ctrl" } },
      { data: { controller: "extra-ctrl" } }
    )

    assert_equal "base-ctrl extra-ctrl", result[:data][:controller]
  end

  def test_space_joins_action_across_data_hashes
    result = instance.merge_html_options(
      { data: { action: "click->a#b" } },
      { data: { action: "keydown->c#d" } }
    )

    assert_equal "click->a#b keydown->c#d", result[:data][:action]
  end

  def test_space_joins_controller_and_action_while_merging_other_data_keys
    result = instance.merge_html_options(
      { data: { controller: "base", action: "click->base#act", foo: "1" } },
      { data: { controller: "extra", action: "keydown->extra#act", bar: "2" } }
    )

    assert_equal "base extra",                         result[:data][:controller]
    assert_equal "click->base#act keydown->extra#act", result[:data][:action]
    assert_equal "1",                                  result[:data][:foo]
    assert_equal "2",                                  result[:data][:bar]
  end

  def test_merge_data_options_space_joins_controller_and_action
    result = instance.merge_data_options(
      { controller: "base", action: "click->base#act" },
      { controller: "extra", action: "keydown->extra#act" }
    )

    assert_equal "base extra",                         result[:controller]
    assert_equal "click->base#act keydown->extra#act", result[:action]
  end

  def test_merge_data_options_preserves_non_stimulus_keys
    result = instance.merge_data_options(
      { controller: "ctrl", target: "el" },
      { foo: "bar" }
    )

    assert_equal "ctrl",  result[:controller]
    assert_equal "el",    result[:target]
    assert_equal "bar",   result[:foo]
  end

  def test_converts_classes_to_class
    result = instance.merge_html_options({ classes: "btn btn-primary" })

    assert_equal "btn btn-primary", result[:class]
    assert_nil result[:classes]
  end

  def test_concatenates_class_and_classes_keys
    result = instance.merge_html_options({ class: "btn", classes: "btn-primary" })

    assert_includes result[:class], "btn"
    assert_includes result[:class], "btn-primary"
  end

  def test_concatenates_class_across_hashes
    result = instance.merge_html_options(
      { class: "theme-class" },
      { class: "user-class" }
    )

    assert_includes result[:class], "theme-class"
    assert_includes result[:class], "user-class"
  end

  def test_preserves_other_top_level_keys
    result = instance.merge_html_options({ id: "foo", aria: { label: "bar" } })

    assert_equal "foo", result[:id]
    assert_equal "bar", result[:aria][:label]
  end
end
