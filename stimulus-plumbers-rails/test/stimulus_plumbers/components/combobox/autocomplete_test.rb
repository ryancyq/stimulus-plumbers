# frozen_string_literal: true

require "test_helper"

class ComboboxAutocompleteTest < ActionView::TestCase
  def render_autocomplete(**opts)
    StimulusPlumbers::Components::Combobox::Autocomplete.new(self).render(**opts)
  end

  # ── structure ─────────────────────────────────────────────────────────────

  def test_renders_listbox
    assert_css parse_html(render_autocomplete), "ul[role='listbox']"
  end

  # ── loading ───────────────────────────────────────────────────────────────

  def test_renders_loading_region
    assert_css parse_html(render_autocomplete), "div[aria-live='polite']"
  end

  def test_loading_is_hidden_by_default
    assert_css parse_html(render_autocomplete), "div[aria-live='polite'][hidden]"
  end

  # ── empty state ───────────────────────────────────────────────────────────

  def test_renders_empty_state_with_role_status
    assert_css parse_html(render_autocomplete), "div[role='status']"
  end

  def test_empty_state_is_hidden_by_default
    assert_css parse_html(render_autocomplete), "div[role='status'][hidden]"
  end

  def test_empty_state_has_no_results_text
    assert_includes parse_html(render_autocomplete).text, "No results"
  end

  # ── options ───────────────────────────────────────────────────────────────

  def test_renders_options
    doc = parse_html(render_autocomplete(options: [%w[London lon], %w[Paris par]]))

    assert_css doc, "li[data-value='lon']"
    assert_css doc, "li[data-value='par']"
  end

  def test_marks_matching_value_as_selected
    assert_css parse_html(render_autocomplete(options: [%w[London lon]], value: "lon")),
               "li[data-value='lon'][aria-selected='true']"
  end

  # ── aria ──────────────────────────────────────────────────────────────────

  def test_aria_label_on_listbox_when_set
    assert_css parse_html(render_autocomplete(label: "Cities")), "ul[aria-label='Cities']"
  end
end
