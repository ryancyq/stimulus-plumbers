# frozen_string_literal: true

require "test_helper"

class ProgressRingTest < ActionView::TestCase
  def renderer
    StimulusPlumbers::Components::ProgressRing.new(self)
  end

  def progress_ring_theme
    Class.new(StimulusPlumbers::Themes::Base) do
      def icons
        {
          "progress-ring" => {
            elements: [
              { tag: :circle, cx: "22", cy: "22", r: "18", class: "track" },
              { tag: :circle, cx: "22", cy: "22", r: "18", class: "fill", data_progress_target: "fill" }
            ]
          }
        }
      end
    end.new
  end

  def with_progress_ring_theme(&block)
    StimulusPlumbers.config.theme.stub(:current, progress_ring_theme, &block)
  end

  def test_wires_progress_controller_ring_variant
    doc = parse_html(renderer.render(value: 25))

    assert_css doc, "[data-controller='progress']"
    assert_css doc, "[data-progress-variant-value='ring']"
    assert_css doc, "[data-progress-current-value='25']"
  end

  def test_sets_aria_valuemin_and_valuemax
    doc = parse_html(renderer.render(value: 25, min: 0, max: 100))

    assert_css doc, "[aria-valuemin='0']"
    assert_css doc, "[aria-valuemax='100']"
  end

  def test_sets_aria_valuenow_unless_indeterminate
    doc = parse_html(renderer.render(value: 25))

    assert_css doc, "[aria-valuenow='25']"
  end

  def test_omits_aria_valuenow_when_indeterminate
    doc = parse_html(renderer.render(value: 0, indeterminate: true))

    assert_no_css doc, "[aria-valuenow]"
  end

  def test_falls_back_to_a_span_when_no_theme_registers_the_icon
    doc = parse_html(renderer.render(value: 25))

    assert_css doc, "span[role='progressbar']"
  end

  def test_renders_svg_with_progressbar_role_when_theme_registers_the_icon
    with_progress_ring_theme do
      doc = parse_html(renderer.render(value: 25))

      assert_css doc, "svg[role='progressbar']"
    end
  end

  def test_accepts_a_size_option
    doc = parse_html(renderer.render(value: 25, size: :lg))

    assert_css doc, "[role='progressbar']"
  end

  def test_renders_track_and_fill_circles_when_theme_registers_the_icon
    with_progress_ring_theme do
      doc = parse_html(renderer.render(value: 25))

      assert_equal 2, doc.css("circle").size
      assert_css doc, "circle[data-progress-target='fill']"
    end
  end

  # Matches the bar and segmented variants: the value is normalized before the JS connects.
  def test_out_of_range_value_is_clamped
    with_progress_ring_theme do
      doc = parse_html(renderer.render(value: 150, max: 100))

      assert_css doc, "[aria-valuenow='100']"
      assert_css doc, "[data-progress-current-value='100']"
    end
  end

  def test_value_below_minimum_is_clamped
    with_progress_ring_theme do
      doc = parse_html(renderer.render(value: -10, min: 0))

      assert_css doc, "[aria-valuenow='0']"
    end
  end
end
