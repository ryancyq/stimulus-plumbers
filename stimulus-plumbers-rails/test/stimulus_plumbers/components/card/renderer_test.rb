# frozen_string_literal: true

require "test_helper"

class CardRendererTest < ActionView::TestCase
  def renderer
    StimulusPlumbers::Components::Card.new(self)
  end

  # ── attr_readers ──────────────────────────────────────────────────────────

  def test_exposes_template
    assert_equal self, renderer.template
  end

  def test_exposes_theme
    assert_equal StimulusPlumbers.config.theme.current, renderer.theme
  end

  # ── card ──────────────────────────────────────────────────────────────────

  def test_card_renders_div
    doc = parse_html(renderer.render { "Content" })

    assert_css doc, "div"
    assert_includes doc.text, "Content"
  end

  def test_card_renders_title_as_h2
    doc = parse_html(renderer.render(title: "My Card") { "" })

    assert_css doc, "h2"
    assert_includes doc.text, "My Card"
  end

  def test_card_omits_heading_when_no_title
    assert_no_css parse_html(renderer.render { "" }), "h2"
  end

  def test_card_renders_title_at_custom_heading_level
    doc = parse_html(renderer.render(title: "My Card", title_tag: :h3) { "" })

    assert_css    doc, "h3"
    assert_no_css doc, "h2"
  end

  def test_card_merges_custom_class
    assert_css parse_html(renderer.render(class: "elevated") { "" }), ".elevated"
  end

  def test_card_passes_html_options
    assert_css parse_html(renderer.render(id: "main-card") { "" }), "#main-card"
  end

  # ── section ───────────────────────────────────────────────────────────────

  def test_section_renders_div
    doc = parse_html(renderer.section { "Section content" })

    assert_css doc, "div"
    assert_includes doc.text, "Section content"
  end

  def test_section_renders_title_as_h3
    doc = parse_html(renderer.section(title: "Section One") { "" })

    assert_css doc, "h3"
    assert_includes doc.text, "Section One"
  end

  def test_section_omits_heading_when_no_title
    assert_no_css parse_html(renderer.section { "" }), "h3"
  end

  def test_section_renders_title_at_custom_heading_level
    doc = parse_html(renderer.section(title: "Section One", title_tag: :h4) { "" })

    assert_css    doc, "h4"
    assert_no_css doc, "h3"
  end

  def test_section_merges_custom_class
    assert_css parse_html(renderer.section(class: "bordered") { "" }), ".bordered"
  end
end
