# frozen_string_literal: true

require "test_helper"

class ComboboxOptionsOptionTest < ActionView::TestCase
  def renderer
    StimulusPlumbers::Components::Combobox::Options::Option.new(self)
  end

  def test_renders_li_with_option_role
    assert_css parse_html(renderer.render(label: "Canada", value: "ca")), "li[role='option']"
  end

  def test_sets_data_value_attribute
    assert_css parse_html(renderer.render(label: "Canada", value: "ca")), "li[data-value='ca']"
  end

  def test_aria_selected_false_by_default
    assert_css parse_html(renderer.render(label: "Canada", value: "ca")), "li[aria-selected='false']"
  end

  def test_aria_selected_true_when_selected
    assert_css parse_html(renderer.render(label: "Canada", value: "ca", selected: true)), "li[aria-selected='true']"
  end

  def test_aria_disabled_when_disabled
    assert_css parse_html(renderer.render(label: "N/A", value: "na", disabled: true)), "li[aria-disabled='true']"
  end

  def test_no_aria_disabled_by_default
    assert_no_css parse_html(renderer.render(label: "Canada", value: "ca")), "[aria-disabled]"
  end

  def test_renders_label_as_text
    assert_includes parse_html(renderer.render(label: "Canada", value: "ca")).text, "Canada"
  end

  def test_renders_description_as_second_span
    doc = parse_html(renderer.render(label: "Canada", value: "ca", description: "North America"))

    assert_equal 2, doc.css("li span").length
    assert_includes doc.text, "North America"
  end

  def test_no_spans_without_description
    assert_equal 0, parse_html(renderer.render(label: "Canada", value: "ca")).css("span").length
  end
end
