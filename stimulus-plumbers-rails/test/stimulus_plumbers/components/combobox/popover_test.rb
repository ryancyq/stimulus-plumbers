# frozen_string_literal: true

require "test_helper"

class ComboboxPopoverTest < ActionView::TestCase
  def render_popover(**opts, &block)
    StimulusPlumbers::Components::Combobox::Popover.new(self).render(
      stimulus_controller: "input-combobox",
      id:                  "combo_popover",
      **opts,
      &block
    )
  end

  # ── structure ─────────────────────────────────────────────────────────────

  def test_renders_element_with_id
    assert_css parse_html(render_popover), "#combo_popover"
  end

  def test_hidden_by_default
    assert_css parse_html(render_popover), "[hidden]"
  end

  def test_default_tag_is_div
    assert_css parse_html(render_popover), "div#combo_popover"
  end

  def test_custom_tag
    assert_css parse_html(render_popover(tag: :section)), "section#combo_popover"
  end

  # ── aria ──────────────────────────────────────────────────────────────────

  def test_role_when_set
    assert_css parse_html(render_popover(role: "dialog")), "[role='dialog']"
  end

  def test_role_omitted_when_nil
    assert_no_css parse_html(render_popover), "[role]"
  end

  def test_aria_label_when_set
    assert_css parse_html(render_popover(label: "Picker")), "[aria-label='Picker']"
  end

  def test_aria_label_omitted_when_nil
    assert_no_css parse_html(render_popover), "[aria-label]"
  end

  # ── content ───────────────────────────────────────────────────────────────

  def test_renders_block_content
    assert_includes parse_html(render_popover { "Popover body" }).text, "Popover body"
  end

  def test_block_receives_id_as_argument
    received_id = nil
    render_popover { |id| received_id = id }

    assert_equal "combo_popover", received_id
  end

  def test_renders_content_kwarg
    assert_includes parse_html(render_popover(content: "Static content")).text, "Static content"
  end

  # ── stimulus ──────────────────────────────────────────────────────────────

  def test_stimulus_popover_target
    assert_css parse_html(render_popover), "[data-input-combobox-target~='popover']"
  end
end
