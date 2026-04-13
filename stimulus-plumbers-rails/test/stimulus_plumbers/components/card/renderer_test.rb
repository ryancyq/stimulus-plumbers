# frozen_string_literal: true

require "test_helper"

class CardRendererTest < ActionView::TestCase
  def renderer
    StimulusPlumbers::Components::Card::Renderer.new(self)
  end

  # attr_readers
  def test_exposes_template
    assert_equal self, renderer.template
  end

  def test_exposes_theme
    assert_equal StimulusPlumbers.config.theme, renderer.theme
  end

  # card
  def test_card_renders_div
    html = renderer.card { "Content" }

    assert_includes html, "<div"
    assert_includes html, "Content"
  end

  def test_card_renders_title_as_h2
    html = renderer.card(title: "My Card") { "" }

    assert_includes html, "<h2"
    assert_includes html, "My Card"
  end

  def test_card_omits_h2_when_no_title
    html = renderer.card { "" }

    refute_includes html, "<h2"
  end

  def test_card_merges_custom_class
    html = renderer.card(class: "elevated") { "" }

    assert_includes html, "elevated"
  end

  def test_card_passes_html_options
    html = renderer.card(id: "main-card") { "" }

    assert_includes html, 'id="main-card"'
  end

  # section
  def test_section_renders_div
    html = renderer.section { "Section content" }

    assert_includes html, "<div"
    assert_includes html, "Section content"
  end

  def test_section_renders_title_as_h3
    html = renderer.section(title: "Section One") { "" }

    assert_includes html, "<h3"
    assert_includes html, "Section One"
  end

  def test_section_omits_h3_when_no_title
    html = renderer.section { "" }

    refute_includes html, "<h3"
  end

  def test_section_merges_custom_class
    html = renderer.section(class: "bordered") { "" }

    assert_includes html, "bordered"
  end
end
