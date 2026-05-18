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

  def test_renders_element_with_id
    html = render_popover

    assert_includes html, 'id="combo_popover"'
  end

  def test_hidden_by_default
    html = render_popover

    assert_includes html, "hidden"
  end

  def test_default_tag_is_div
    html = render_popover

    assert_includes html, "<div"
  end

  def test_custom_tag
    html = render_popover(tag: :section)

    assert_includes html, "<section"
  end

  def test_role_when_set
    html = render_popover(role: "dialog")

    assert_includes html, 'role="dialog"'
  end

  def test_role_omitted_when_nil
    html = render_popover

    refute_includes html, "role="
  end

  def test_aria_label_when_set
    html = render_popover(label: "Picker")

    assert_includes html, 'aria-label="Picker"'
  end

  def test_aria_label_omitted_when_nil
    html = render_popover

    refute_includes html, "aria-label"
  end

  def test_renders_block_content
    html = render_popover { "Popover body" }

    assert_includes html, "Popover body"
  end

  def test_renders_content_kwarg
    html = render_popover(content: "Static content")

    assert_includes html, "Static content"
  end

  def test_stimulus_popover_target
    html = render_popover

    assert_includes html, "input-combobox-target"
  end
end
