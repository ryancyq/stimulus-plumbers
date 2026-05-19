# frozen_string_literal: true

require "test_helper"

class ComboboxDropdownTest < ActionView::TestCase
  def render_dropdown(**opts)
    StimulusPlumbers::Components::Combobox::Dropdown.new(self).render(**opts)
  end

  # ── structure ─────────────────────────────────────────────────────────────

  def test_renders_ul_element
    assert_css parse_html(render_dropdown), "ul"
  end

  def test_role_is_listbox
    assert_css parse_html(render_dropdown), "ul[role='listbox']"
  end

  # ── options ───────────────────────────────────────────────────────────────

  def test_renders_options
    doc = parse_html(render_dropdown(options: [["Canada", "ca"], ["United States", "us"]]))

    assert_css doc, "li[role='option'][data-value='ca']"
    assert_css doc, "li[role='option'][data-value='us']"
  end

  def test_marks_matching_value_as_selected
    doc = parse_html(render_dropdown(options: [["Canada", "ca"], ["United States", "us"]], value: "ca"))

    assert_css doc, "li[data-value='ca'][aria-selected='true']"
    assert_css doc, "li[data-value='us'][aria-selected='false']"
  end

  # ── aria ──────────────────────────────────────────────────────────────────

  def test_aria_label_when_set
    assert_css parse_html(render_dropdown(label: "Choose country")), "ul[aria-label='Choose country']"
  end

  def test_aria_label_omitted_when_nil
    assert_no_css parse_html(render_dropdown), "ul[aria-label]"
  end

  def test_aria_labelledby_when_set
    assert_css parse_html(render_dropdown(labelledby: "country_label")), "ul[aria-labelledby='country_label']"
  end

  def test_aria_labelledby_omitted_when_nil
    assert_no_css parse_html(render_dropdown), "ul[aria-labelledby]"
  end

  def test_labelledby_takes_precedence_over_label
    doc = parse_html(render_dropdown(label: "Choose country", labelledby: "country_label"))

    assert_css    doc, "ul[aria-labelledby='country_label']"
    assert_no_css doc, "ul[aria-label]"
  end

  # ── stimulus ──────────────────────────────────────────────────────────────

  def test_stimulus_listbox_target
    assert_css parse_html(render_dropdown), "[data-combobox-dropdown-target~='listbox']"
  end
end
