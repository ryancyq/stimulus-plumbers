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

  def test_renders_input_element
    html = render_trigger

    assert_includes html, "<input"
  end

  def test_input_type_is_text
    html = render_trigger

    assert_includes html, 'type="text"'
  end

  def test_role_is_combobox
    html = render_trigger

    assert_includes html, 'role="combobox"'
  end

  def test_aria_expanded_is_false
    html = render_trigger

    assert_includes html, 'aria-expanded="false"'
  end

  def test_aria_haspopup
    html = render_trigger(haspopup: "listbox")

    assert_includes html, 'aria-haspopup="listbox"'
  end

  def test_aria_controls_points_to_popover
    html = render_trigger

    assert_includes html, 'aria-controls="combo_popover"'
  end

  def test_readonly_by_default
    html = render_trigger

    assert_includes html, "readonly"
  end

  def test_readonly_false_omits_attribute
    html = render_trigger(readonly: false)

    refute_includes html, "readonly"
  end

  def test_aria_autocomplete_when_set
    html = render_trigger(aria_autocomplete: "list")

    assert_includes html, 'aria-autocomplete="list"'
  end

  def test_aria_autocomplete_omitted_when_nil
    html = render_trigger

    refute_includes html, "aria-autocomplete"
  end

  def test_aria_label_when_set
    html = render_trigger(aria_label: "Country")

    assert_includes html, 'aria-label="Country"'
  end

  def test_aria_invalid_forwarded_via_aria_kwarg
    html = render_trigger(aria: { invalid: "true" })

    assert_includes html, 'aria-invalid="true"'
  end

  def test_aria_invalid_does_not_clobber_structural_aria
    html = render_trigger(aria: { invalid: "true" })

    assert_includes html, 'aria-expanded="false"'
    assert_includes html, 'aria-haspopup="listbox"'
    assert_includes html, 'aria-controls="combo_popover"'
  end

  def test_stimulus_target_data_attribute
    html = render_trigger

    assert_includes html, "input-combobox-target"
  end
end
