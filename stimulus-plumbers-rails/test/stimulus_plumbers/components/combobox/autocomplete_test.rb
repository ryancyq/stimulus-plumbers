# frozen_string_literal: true

require "test_helper"

class ComboboxAutocompleteTest < ActionView::TestCase
  def render_autocomplete(**opts)
    StimulusPlumbers::Components::Combobox::Autocomplete.new(self).render(**opts)
  end

  def test_renders_listbox
    doc = parse_html(render_autocomplete)

    assert_css doc, "ul[role='listbox']"
  end

  def test_renders_loading_region
    doc = parse_html(render_autocomplete)

    assert_css doc, "div[aria-live='polite']"
  end

  def test_loading_is_hidden_by_default
    doc = parse_html(render_autocomplete)

    assert_css doc, "div[aria-live='polite'][hidden]"
  end

  def test_renders_empty_state_with_role_status
    doc = parse_html(render_autocomplete)

    assert_css doc, "div[role='status']"
  end

  def test_empty_state_is_hidden_by_default
    doc = parse_html(render_autocomplete)

    assert_css doc, "div[role='status'][hidden]"
  end

  def test_empty_state_has_no_results_text
    html = render_autocomplete

    assert_includes html, "No results"
  end

  def test_renders_options
    doc = parse_html(render_autocomplete(options: [["London", "lon"], ["Paris", "par"]]))

    assert_css doc, "li[data-value='lon']"
    assert_css doc, "li[data-value='par']"
  end

  def test_marks_matching_value_as_selected
    doc = parse_html(render_autocomplete(options: [["London", "lon"]], value: "lon"))

    assert_css doc, "li[data-value='lon'][aria-selected='true']"
  end

  def test_aria_label_on_listbox_when_set
    html = render_autocomplete(label: "Cities")

    assert_includes html, 'aria-label="Cities"'
  end
end
