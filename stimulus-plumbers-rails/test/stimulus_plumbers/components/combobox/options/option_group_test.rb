# frozen_string_literal: true

require "test_helper"

class ComboboxOptionsOptionGroupTest < ActionView::TestCase
  def renderer
    StimulusPlumbers::Components::Combobox::Options::OptionGroup.new(self)
  end

  def test_renders_li_with_group_role
    assert_css parse_html(renderer.render(label: "Americas", options: [])), "li[role='group']"
  end

  def test_sets_aria_label_on_group
    assert_css parse_html(renderer.render(label: "Americas", options: [])), "li[aria-label='Americas']"
  end

  def test_renders_label_in_aria_hidden_span
    doc = parse_html(renderer.render(label: "Americas", options: []))

    assert_css doc, "span[aria-hidden='true']"
    assert_includes doc.at_css("span[aria-hidden]").text, "Americas"
  end

  def test_renders_options_in_nested_ul
    doc = parse_html(renderer.render(label: "Americas", options: [%w[Canada ca]]))

    assert_css doc, "li[role='group'] > ul > li[role='option'][data-value='ca']"
  end

  def test_marks_selected_option_by_value
    doc = parse_html(renderer.render(label: "Americas", options: [%w[Canada ca], %w[US us]], value: "ca"))

    assert_css doc, "li[data-value='ca'][aria-selected='true']"
    assert_css doc, "li[data-value='us'][aria-selected='false']"
  end
end
