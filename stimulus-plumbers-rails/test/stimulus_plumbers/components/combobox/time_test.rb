# frozen_string_literal: true

require "test_helper"

class ComboboxTimeTest < ActionView::TestCase
  def render_time(**opts)
    StimulusPlumbers::Components::Combobox::Time.new(self).render(**opts)
  end

  def test_renders_wrapper_div
    html = render_time

    assert_includes html, "<div"
  end

  def test_has_combobox_time_controller
    html = render_time

    assert_includes html, "combobox-time"
  end

  def test_h12_renders_three_drums
    doc = parse_html(render_time(format: :h12))

    assert_equal 3, doc.css("ul[role='listbox']").length
  end

  def test_h24_renders_two_drums
    doc = parse_html(render_time(format: :h24))

    assert_equal 2, doc.css("ul[role='listbox']").length
  end

  def test_drums_have_listbox_role
    doc = parse_html(render_time)

    assert_css doc, "ul[role='listbox']"
  end

  def test_hour_drum_has_label
    doc = parse_html(render_time)

    assert_css doc, "ul[aria-label='Hour']"
  end

  def test_minute_drum_has_label
    doc = parse_html(render_time)

    assert_css doc, "ul[aria-label='Minute']"
  end

  def test_period_drum_has_label_in_h12
    doc = parse_html(render_time(format: :h12))

    assert_css doc, "ul[aria-label='Period']"
  end

  def test_period_drum_absent_in_h24
    doc = parse_html(render_time(format: :h24))

    assert_no_css doc, "ul[aria-label='Period']"
  end

  def test_selects_correct_hour_from_value
    doc = parse_html(render_time(format: :h12, value: "14:30"))

    assert_css doc, "ul[aria-label='Hour'] li[aria-selected='true']"
    selected = doc.at_css("ul[aria-label='Hour'] li[aria-selected='true']")
    assert_equal "2", selected.text.strip
  end

  def test_selects_correct_minute_from_value
    doc = parse_html(render_time(value: "09:45"))

    selected = doc.at_css("ul[aria-label='Minute'] li[aria-selected='true']")
    assert_equal "45", selected.text.strip
  end

  def test_step_reduces_minute_options
    doc_step1  = parse_html(render_time(step: 1))
    doc_step15 = parse_html(render_time(step: 15))

    count_1  = doc_step1.css("ul[aria-label='Minute'] li").length
    count_15 = doc_step15.css("ul[aria-label='Minute'] li").length

    assert_operator count_15, :<, count_1
    assert_equal 4, count_15
  end

  def test_invalid_value_renders_without_selection
    doc = parse_html(render_time(value: "not-a-time"))

    assert_no_css doc, "li[aria-selected='true']"
  end
end
