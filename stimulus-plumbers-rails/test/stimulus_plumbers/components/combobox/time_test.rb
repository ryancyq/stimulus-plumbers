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

  def test_drums_have_tabindex_zero
    doc = parse_html(render_time)
    drums = doc.css("ul[role='listbox']")

    assert(drums.all? { |ul| ul["tabindex"] == "0" })
  end

  def test_drums_have_stimulus_target
    doc = parse_html(render_time)

    assert_css doc, "ul[data-combobox-time-target='hour']"
    assert_css doc, "ul[data-combobox-time-target='minute']"
  end

  def test_drums_have_click_action
    assert_includes render_time, "click-&gt;combobox-time#select"
  end

  def test_drums_have_keydown_navigate_action
    assert_includes render_time, "keydown-&gt;combobox-time#onNavigate"
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

  def test_period_drum_shows_localized_am_pm_labels
    doc = parse_html(render_time(format: :h12))

    items = doc.css("ul[aria-label='Period'] li")

    assert_equal "AM", items[0].text.strip
    assert_equal "PM", items[1].text.strip
  end

  def test_period_drum_uses_canonical_am_pm_values
    doc = parse_html(render_time(format: :h12))

    assert_css doc, "ul[aria-label='Period'] li[data-value='AM']"
    assert_css doc, "ul[aria-label='Period'] li[data-value='PM']"
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

  def test_selects_correct_period_from_value
    doc_am = parse_html(render_time(format: :h12, value: "09:00"))
    doc_pm = parse_html(render_time(format: :h12, value: "14:00"))

    assert_css doc_am, "ul[aria-label='Period'] li[data-value='AM'][aria-selected='true']"
    assert_css doc_pm, "ul[aria-label='Period'] li[data-value='PM'][aria-selected='true']"
  end

  def test_step_reduces_minute_options
    doc_step1  = parse_html(render_time(step: 1))
    doc_step15 = parse_html(render_time(step: 15))

    every_minute_count  = doc_step1.css("ul[aria-label='Minute'] li").length
    every_quarter_count = doc_step15.css("ul[aria-label='Minute'] li").length

    assert_operator every_quarter_count, :<, every_minute_count
    assert_equal 4, every_quarter_count
  end

  def test_invalid_value_renders_without_selection
    doc = parse_html(render_time(value: "not-a-time"))

    assert_no_css doc, "li[aria-selected='true']"
  end

  def test_variant_metadata
    meta = StimulusPlumbers::Components::Combobox::Time::Metadata

    assert_equal "dialog", meta.haspopup
    assert_equal "clock", meta.trigger_icon

    data = meta.stimulus_data("p1", { format: :h24 })

    assert_equal "time", data[:input_formatter_format_value]
    assert_equal({ format: :h24 }.to_json, data[:input_formatter_options_value])
  end
end
