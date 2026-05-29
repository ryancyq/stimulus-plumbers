# frozen_string_literal: true

require "test_helper"

class ComboboxTest < ActionView::TestCase
  def render_combobox(input: {}, trigger: {}, **kwargs)
    StimulusPlumbers::Components::Combobox.new(self).render(
      input:   input,
      trigger: trigger,
      **kwargs
    ) do |_panel_id, panel_attrs|
      content_tag(:ul, "popover-content".html_safe, **panel_attrs)
    end
  end

  # ── stimulus controllers ───────────────────────────────────────────────────

  def test_wrapper_includes_input_combobox_controller
    doc = parse_html(render_combobox)

    assert_css doc, "[data-controller~='input-combobox']"
  end

  def test_wrapper_includes_input_formatter_controller
    doc = parse_html(render_combobox)

    assert_css doc, "[data-controller~='input-formatter']"
  end

  def test_wrapper_includes_format_action
    doc = parse_html(render_combobox)

    assert_css doc, "[data-action~='input-combobox:changed->input-formatter#format']"
  end

  # ── initial value wiring ───────────────────────────────────────────────────

  def test_value_data_attribute_set_when_input_value_present
    doc = parse_html(render_combobox(input: { value: "2024-03-15" }))

    assert_css doc, "[data-input-combobox-value-value='2024-03-15']"
  end

  def test_value_data_attribute_absent_when_input_value_nil
    doc = parse_html(render_combobox(input: { value: nil }))

    assert_no_css doc, "[data-input-combobox-value-value]"
  end

  def test_value_data_attribute_absent_when_input_value_blank
    doc = parse_html(render_combobox(input: { value: "" }))

    assert_no_css doc, "[data-input-combobox-value-value]"
  end

  def test_value_data_attribute_absent_when_input_omitted
    doc = parse_html(render_combobox)

    assert_no_css doc, "[data-input-combobox-value-value]"
  end

  # ── hidden input ───────────────────────────────────────────────────────────

  def test_hidden_input_value_reflects_input_value
    doc = parse_html(render_combobox(input: { value: "us" }))

    assert_css doc, "input[type='hidden'][value='us']"
  end

  def test_hidden_input_name_reflects_input_name
    doc = parse_html(render_combobox(input: { name: "country", value: "us" }))

    assert_css doc, "input[type='hidden'][name='country']"
  end

  # ── popover id linkage ─────────────────────────────────────────────────────

  def test_trigger_aria_controls_matches_popover_id
    doc     = parse_html(render_combobox(trigger: { id: "combo" }))
    trigger = doc.at_css("input[role='combobox']")
    popover = doc.at_css("[id='combo_popover']")

    assert_not_nil trigger
    assert_not_nil popover
    assert_equal "combo_popover", trigger["aria-controls"]
  end

  # ── html options passthrough ───────────────────────────────────────────────

  def test_extra_html_options_forwarded_to_wrapper
    doc = parse_html(render_combobox(class: "my-combobox"))

    assert_css doc, "div.my-combobox[data-controller~='input-combobox']"
  end

  def test_extra_data_attrs_merged_with_stimulus_data
    doc = parse_html(render_combobox(data: { testid: "cb" }))

    assert_css doc, "[data-testid='cb'][data-controller~='input-combobox']"
  end
end
