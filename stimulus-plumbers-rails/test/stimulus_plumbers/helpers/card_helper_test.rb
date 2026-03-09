# frozen_string_literal: true

require "test_helper"

class CardHelperTest < ActionView::TestCase
  include StimulusPlumbers::Helpers::CardHelper

  def test_renders_card_div
    html = sp_card { "Content" }

    assert_includes html, "<div"
    assert_includes html, "Content"
  end

  def test_renders_title_as_h2
    html = sp_card(title: "My Card") { "" }

    assert_includes html, "<h2"
    assert_includes html, "My Card"
  end

  def test_renders_no_title_when_absent
    html = sp_card { "" }

    refute_includes html, "<h2"
  end

  def test_merges_custom_class
    html = sp_card(class: "elevated") { "" }

    assert_includes html, "elevated"
  end

  def test_passes_html_options
    html = sp_card(id: "main-card") { "" }

    assert_includes html, 'id="main-card"'
  end

  def test_section_renders_div
    html = sp_card_section { "Section content" }

    assert_includes html, "<div"
    assert_includes html, "Section content"
  end

  def test_section_renders_title_as_h3
    html = sp_card_section(title: "Section One") { "" }

    assert_includes html, "<h3"
    assert_includes html, "Section One"
  end

  def test_section_renders_no_title_when_absent
    html = sp_card_section { "" }

    refute_includes html, "<h3"
  end

  def test_composition
    html = sp_card(title: "Card") do
      sp_card_section(title: "Section 1") { "Content 1" }
    end

    assert_includes html, "<h2"
    assert_includes html, "Card"
    assert_includes html, "<h3"
    assert_includes html, "Section 1"
    assert_includes html, "Content 1"
  end
end
