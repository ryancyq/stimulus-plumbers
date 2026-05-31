# frozen_string_literal: true

require "test_helper"

class CardHelperTest < ActionView::TestCase
  include StimulusPlumbers::Helpers::CardHelper

  def test_renders_card_div
    doc = parse_html(sp_card { "Content" })

    assert_css doc, "div"
    assert_includes doc.text, "Content"
  end

  def test_renders_title_as_h2
    doc = parse_html(sp_card(title: "My Card") { "" })

    assert_css doc, "h2"
    assert_includes doc.text, "My Card"
  end

  def test_renders_no_heading_when_title_absent
    assert_no_css parse_html(sp_card { "" }), "h2"
  end

  def test_renders_title_at_custom_heading_level
    doc = parse_html(sp_card(title: "My Card", title_tag: :h3) { "" })

    assert_css    doc, "h3"
    assert_no_css doc, "h2"
  end

  def test_merges_custom_class
    assert_css parse_html(sp_card(class: "elevated") { "" }), ".elevated"
  end

  def test_passes_html_options
    assert_css parse_html(sp_card(id: "main-card") { "" }), "#main-card"
  end

  def test_section_renders_div
    doc = parse_html(sp_card_section { "Section content" })

    assert_css doc, "div"
    assert_includes doc.text, "Section content"
  end

  def test_section_renders_title_as_h3
    doc = parse_html(sp_card_section(title: "Section One") { "" })

    assert_css doc, "h3"
    assert_includes doc.text, "Section One"
  end

  def test_section_renders_no_heading_when_title_absent
    assert_no_css parse_html(sp_card_section { "" }), "h3"
  end

  def test_section_renders_title_at_custom_heading_level
    doc = parse_html(sp_card_section(title: "Section One", title_tag: :h4) { "" })

    assert_css    doc, "h4"
    assert_no_css doc, "h3"
  end

  def test_section_merges_custom_class
    assert_css parse_html(sp_card_section(class: "bordered") { "" }), ".bordered"
  end

  def test_composition
    doc = parse_html(
      sp_card(title: "Card") do
        sp_card_section(title: "Section 1") { "Content 1" }
      end
    )

    assert_css doc, "h2"
    assert_css doc, "h3"
    assert_includes doc.text, "Card"
    assert_includes doc.text, "Section 1"
    assert_includes doc.text, "Content 1"
  end
end
