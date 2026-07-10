# frozen_string_literal: true

require "test_helper"

class ProgressMeterTest < ActionView::TestCase
  def renderer
    StimulusPlumbers::Components::ProgressMeter.new(self)
  end

  def test_renders_meter_element
    assert_css parse_html(renderer.render(value: 40)), "meter"
  end

  def test_sets_native_value_min_max_attrs
    doc = parse_html(renderer.render(value: 40, min: 0, max: 100))

    assert_css doc, "meter[value='40']"
    assert_css doc, "meter[min='0']"
    assert_css doc, "meter[max='100']"
  end

  def test_sets_low_high_optimum_when_given
    doc = parse_html(renderer.render(value: 40, low: 20, high: 80, optimum: 50))

    assert_css doc, "meter[low='20']"
    assert_css doc, "meter[high='80']"
    assert_css doc, "meter[optimum='50']"
  end

  def test_omits_low_high_optimum_when_not_given
    doc = parse_html(renderer.render(value: 40))

    assert_no_css doc, "meter[low]"
    assert_no_css doc, "meter[high]"
    assert_no_css doc, "meter[optimum]"
  end

  def test_wires_progress_controller_meter_variant
    doc = parse_html(renderer.render(value: 40))

    assert_css doc, "meter[data-controller='progress']"
    assert_css doc, "meter[data-progress-variant-value='meter']"
    assert_css doc, "meter[data-progress-target='meter']"
  end

  def test_has_no_progressbar_role
    assert_no_css parse_html(renderer.render(value: 40)), "meter[role='progressbar']"
  end
end
