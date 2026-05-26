# frozen_string_literal: true

require "test_helper"

class ComboboxTriggerTest < ActionView::TestCase
  def render_trigger(**opts)
    StimulusPlumbers::Components::Combobox::Trigger.new(self).render(
      stimulus_controller: "input-combobox",
      popover_id:          "combo_popover",
      haspopup:            "listbox",
      **opts
    )
  end

  # ── structure ─────────────────────────────────────────────────────────────

  def test_renders_input_element
    assert_css parse_html(render_trigger), "input"
  end

  def test_input_type_is_text
    assert_css parse_html(render_trigger), "input[type='text']"
  end

  def test_role_is_combobox
    assert_css parse_html(render_trigger), "input[role='combobox']"
  end

  def test_readonly_by_default
    assert_css parse_html(render_trigger), "input[readonly]"
  end

  def test_readonly_false_omits_attribute
    assert_no_css parse_html(render_trigger(readonly: false)), "input[readonly]"
  end

  # ── aria ──────────────────────────────────────────────────────────────────

  def test_aria_expanded_is_false
    assert_css parse_html(render_trigger), "input[aria-expanded='false']"
  end

  def test_aria_haspopup
    assert_css parse_html(render_trigger(haspopup: "listbox")), "input[aria-haspopup='listbox']"
  end

  def test_aria_controls_points_to_popover
    assert_css parse_html(render_trigger), "input[aria-controls='combo_popover']"
  end

  def test_aria_autocomplete_when_set
    assert_css parse_html(render_trigger(aria: { autocomplete: "list" })), "input[aria-autocomplete='list']"
  end

  def test_aria_autocomplete_omitted_when_nil
    assert_no_css parse_html(render_trigger), "input[aria-autocomplete]"
  end

  def test_aria_label_when_set
    assert_css parse_html(render_trigger(aria: { label: "Country" })), "input[aria-label='Country']"
  end

  def test_aria_invalid_forwarded_via_aria_kwarg
    assert_css parse_html(render_trigger(aria: { invalid: "true" })), "input[aria-invalid='true']"
  end

  def test_aria_invalid_does_not_clobber_structural_aria
    doc = parse_html(render_trigger(aria: { invalid: "true" }))

    assert_css doc, "input[aria-expanded='false']"
    assert_css doc, "input[aria-haspopup='listbox']"
    assert_css doc, "input[aria-controls='combo_popover']"
  end

  # ── stimulus ──────────────────────────────────────────────────────────────

  def test_stimulus_target_data_attribute
    assert_css parse_html(render_trigger), "[data-input-combobox-target~='trigger']"
  end
end
