# frozen_string_literal: true

require "test_helper"

class DividerHelperTest < ActionView::TestCase
  include StimulusPlumbers::Helpers::DividerHelper

  def test_renders_hr_element
    assert_includes sp_divider, "<hr"
  end

  def test_merges_custom_class
    assert_includes sp_divider(class: "separator"), "separator"
  end

  # ── labeled divider ────────────────────────────────────────────────────────

  def test_labeled_renders_div_with_role_separator
    doc = parse_html(sp_divider("or"))

    assert_css doc, "div[role='separator']"
  end

  def test_labeled_renders_span_with_label_text
    doc = parse_html(sp_divider("or"))

    assert_includes doc.at_css("span").text, "or"
  end

  def test_no_label_renders_hr_inside_wrapper
    doc = parse_html(sp_divider)

    assert_css doc, "div[role='separator'] hr"
    assert_no_css doc, "span"
  end
end
