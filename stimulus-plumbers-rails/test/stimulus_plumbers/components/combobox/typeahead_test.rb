# frozen_string_literal: true

require "test_helper"

class ComboboxTypeaheadTest < ActionView::TestCase
  def render_typeahead(**opts)
    StimulusPlumbers::Components::Combobox::Typeahead.new(self).render(**opts)
  end

  # ── loading ───────────────────────────────────────────────────────────────

  def test_renders_loading_region
    assert_css parse_html(render_typeahead), "li[aria-live='polite']"
  end

  def test_loading_is_hidden_by_default
    assert_css parse_html(render_typeahead), "li[aria-live='polite'][hidden]"
  end

  # ── empty state ───────────────────────────────────────────────────────────

  def test_renders_empty_state_with_role_status
    assert_css parse_html(render_typeahead), "li[role='status']"
  end

  def test_empty_state_is_hidden_by_default
    assert_css parse_html(render_typeahead), "li[role='status'][hidden]"
  end

  def test_empty_state_has_no_results_text
    assert_includes parse_html(render_typeahead).text, "No results"
  end

  # ── options ───────────────────────────────────────────────────────────────

  def test_renders_options
    doc = parse_html(render_typeahead(options: [%w[London lon], %w[Paris par]]))

    assert_css doc, "li[data-value='lon']"
    assert_css doc, "li[data-value='par']"
  end

  def test_marks_matching_value_as_selected
    assert_css parse_html(render_typeahead(options: [%w[London lon]], value: "lon")),
               "li[data-value='lon'][aria-selected='true']"
  end
end
