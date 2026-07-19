# frozen_string_literal: true

require "test_helper"

class IndicatorTest < ActionView::TestCase
  def renderer
    StimulusPlumbers::Components::Indicator.new(self)
  end

  def test_renders_a_span
    assert_css parse_html(renderer.render(variant: :success)), "span"
  end

  def test_dot_type_is_empty_by_default
    doc = parse_html(renderer.render(type: :dot, variant: :success))

    assert_equal "", doc.css("span").first.text.strip
  end

  def test_badge_type_renders_provided_content
    doc = parse_html(renderer.render(type: :badge, variant: :primary) { "5" })

    assert_includes doc.text, "5"
  end

  def test_pulse_true_wraps_the_dot_with_a_ring_element
    doc = parse_html(renderer.render(variant: :warning, pulse: true))

    assert_equal 3, doc.css("span").size
  end

  def test_pulse_false_renders_only_the_dot
    doc = parse_html(renderer.render(variant: :warning, pulse: false))

    assert_equal 1, doc.css("span").size
  end

  def test_pulse_ring_is_aria_hidden
    doc = parse_html(renderer.render(variant: :warning, pulse: true))

    assert_css doc, "span[aria-hidden='true']"
  end

  def test_merges_custom_html_options
    assert_css parse_html(renderer.render(variant: :success, id: "my-indicator")), "span#my-indicator"
  end

  def test_variant_defaults_when_omitted
    assert_css parse_html(renderer.render), "span"
  end

  def wrapper_theme
    Class.new(StimulusPlumbers::Themes::Base) do
      private

      def indicator_classes(**)
        {}
      end

      def indicator_wrapper_classes
        { classes: "wrapper-test" }
      end

      def indicator_pulse_classes
        {}
      end
    end.new
  end

  def test_wrapper_theme_classes_render_as_a_class_attribute
    StimulusPlumbers.config.theme.stub(:current, wrapper_theme) do
      doc = parse_html(renderer.render(variant: :warning, pulse: true))

      assert_css doc, "span.wrapper-test"
      assert_no_css doc, "span[classes]"
    end
  end
end
