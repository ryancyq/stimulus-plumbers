# frozen_string_literal: true

require "test_helper"

class ComboboxDropdownTest < ActionView::TestCase
  def render_dropdown(**opts)
    StimulusPlumbers::Components::Combobox::Dropdown.new(self).render(**opts)
  end

  def test_renders_ul_element
    html = render_dropdown

    assert_includes html, "<ul"
  end

  def test_role_is_listbox
    html = render_dropdown

    assert_includes html, 'role="listbox"'
  end

  def test_renders_options
    html = render_dropdown(options: [["Canada", "ca"], ["United States", "us"]])

    assert_includes html, "Canada"
    assert_includes html, "United States"
  end

  def test_marks_matching_value_as_selected
    doc = parse_html(render_dropdown(options: [["Canada", "ca"], ["United States", "us"]], value: "ca"))

    assert_css doc, "li[data-value='ca'][aria-selected='true']"
    assert_css doc, "li[data-value='us'][aria-selected='false']"
  end

  def test_aria_label_when_set
    html = render_dropdown(label: "Choose country")

    assert_includes html, 'aria-label="Choose country"'
  end

  def test_aria_label_omitted_when_nil
    html = render_dropdown

    refute_includes html, "aria-label"
  end

  def test_stimulus_listbox_target
    html = render_dropdown

    assert_includes html, "listbox"
  end
end
