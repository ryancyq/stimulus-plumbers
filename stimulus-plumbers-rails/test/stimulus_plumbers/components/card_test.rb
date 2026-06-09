# frozen_string_literal: true

require "test_helper"

class CardComponentTest < ActionView::TestCase
  def renderer
    StimulusPlumbers::Components::Card.new(self)
  end

  def test_exposes_template
    assert_equal self, renderer.template
  end

  def test_exposes_theme
    assert_equal StimulusPlumbers.config.theme.current, renderer.theme
  end

  def test_card_root_element_is_div
    assert_css parse_html(renderer.render { |card| card.with_title("Card") }), "div"
  end

  def test_card_merges_custom_class
    assert_css parse_html(renderer.render(class: "elevated") { |card| card.with_title("Card") }), ".elevated"
  end

  def test_card_passes_html_options
    assert_css parse_html(renderer.render(id: "main-card") { |card| card.with_title("Card") }), "#main-card"
  end

  def test_card_renders_title_as_h2_by_default
    doc = parse_html(renderer.render { |card| card.with_title("My Card") })

    assert_css doc, "h2"
    assert_includes doc.text, "My Card"
  end

  def test_card_title_tag_can_be_overridden
    doc = parse_html(renderer.render(title_tag: :h3) { |card| card.with_title("My Card") })

    assert_css    doc, "h3"
    assert_no_css doc, "h2"
  end

  def test_card_renders_icon_in_header
    doc = parse_html(
      renderer.render do |card|
        card.with_title("Profile")
        card.with_icon("user")
      end
    )

    assert_css doc, "div > div"
    assert_css doc, "span[aria-hidden='true']"
  end

  def test_card_header_absent_when_no_title_and_no_icon
    doc = parse_html(renderer.render { |card| card.with_body { "Content" } })

    assert_no_css doc, "h2"
  end

  def test_card_omits_header_when_empty_block
    doc = parse_html(renderer.render { |card| card })

    assert_no_css doc, "h2"
    assert_no_css doc, "svg"
  end

  def test_card_body_raises_on_string
    assert_raises(ArgumentError) { renderer.render { |card| card.with_body("Manage your profile") } }
  end

  def test_card_body_renders_block_content
    doc = parse_html(renderer.render { |card| card.with_body { content_tag(:ul) { content_tag(:li, "Item") } } })

    assert_css    doc, "ul"
    assert_no_css doc, "p"
  end

  def test_card_omits_body_when_not_set
    doc = parse_html(renderer.render { |card| card.with_title("Card") })

    assert_no_css doc, "p"
  end

  def test_card_renders_with_non_default_variant
    assert_css parse_html(renderer.render(variant: :primary) { |card| card.with_title("Card") }), "div"
  end

  def test_card_renders_link_action_when_url_given
    doc = parse_html(
      renderer.render do |card|
        card.with_title("Card")
        card.with_action("View", url: "/profile")
      end
    )

    assert_css doc, "a[href='/profile']"
    assert_includes doc.text, "View"
  end

  def test_card_renders_button_action_without_url
    doc = parse_html(
      renderer.render do |card|
        card.with_title("Card")
        card.with_action("Click me")
      end
    )

    assert_css doc, "button[type='button']"
    assert_includes doc.text, "Click me"
  end

  def test_card_action_accepts_block_content
    doc = parse_html(
      renderer.render do |card|
        card.with_action(url: "/profile") { content_tag(:span, "Go") }
      end
    )

    assert_css doc, "a[href='/profile']"
    assert_includes doc.text, "Go"
  end

  def test_card_omits_action_when_not_set
    doc = parse_html(renderer.render { |card| card.with_title("Card") })

    assert_no_css doc, "a"
    assert_no_css doc, "button"
  end
end
