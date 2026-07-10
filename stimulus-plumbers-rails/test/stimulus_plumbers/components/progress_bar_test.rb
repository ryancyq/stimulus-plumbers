# frozen_string_literal: true

require "test_helper"

class ProgressBarTest < ActionView::TestCase
  def renderer
    StimulusPlumbers::Components::ProgressBar.new(self)
  end

  def test_renders_progressbar_role
    assert_css parse_html(renderer.render(value: 30)), "div[role='progressbar']"
  end

  def test_renders_aria_value_attrs
    doc = parse_html(renderer.render(value: 30, max: 100))

    assert_css doc, "div[aria-valuenow='30']"
    assert_css doc, "div[aria-valuemin='0']"
    assert_css doc, "div[aria-valuemax='100']"
  end

  def test_renders_fill_target
    assert_css parse_html(renderer.render(value: 30)), "div[data-progress-target='fill']"
  end

  def test_wires_progress_controller_and_values
    doc = parse_html(renderer.render(value: 30, min: 0, max: 100))

    assert_css doc, "div[data-controller='progress']"
    assert_css doc, "div[data-progress-variant-value='bar']"
    assert_css doc, "div[data-progress-current-value='30']"
    assert_css doc, "div[data-progress-min-value='0']"
    assert_css doc, "div[data-progress-max-value='100']"
  end

  def test_indeterminate_omits_aria_valuenow
    doc = parse_html(renderer.render(value: 0, indeterminate: true))

    assert_no_css doc, "div[aria-valuenow]"
    assert_css doc, "div[data-progress-indeterminate-value='true']"
  end

  def test_merges_custom_html_options
    assert_css parse_html(renderer.render(value: 30, id: "my-progress")), "div#my-progress"
  end
end
