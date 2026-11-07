# frozen_string_literal: true

require "test_helper"

class ComboboxTriggerTest < ActionView::TestCase
  def render_trigger(**kwargs)
    parse_html(
      StimulusPlumbers::Components::Combobox::Trigger.new(self).render(
        id: "city", listbox_id: "city_listbox", aria: { label: "City" }, **kwargs
      ) { |attrs| tag.button("Seoul", type: "button", **attrs) }
    )
  end

  def test_block_renders_the_host_with_the_combobox_attributes
    control = render_trigger.at_css("[role='combobox']")

    assert_equal "button", control.name
    assert_equal "Seoul", control.text
    assert_equal "trigger", control["data-combobox-target"]
    assert_equal "keydown->combobox#onKeydown", control["data-action"]
  end

  def test_actions_run_before_keydown
    control = render_trigger(actions: ["input->combobox#onInput"]).at_css("[role='combobox']")

    assert_equal "input->combobox#onInput keydown->combobox#onKeydown", control["data-action"]
  end

  def test_names_the_control_and_references_the_listbox
    control = render_trigger.at_css("[role='combobox']")

    assert_equal "City", control["aria-label"]
    assert_equal "city_listbox", control["aria-controls"]
    assert_equal "false", control["aria-expanded"]
  end

  def test_icons_sit_beside_the_host
    assert_css render_trigger(icon_trailing: "chevron-down"), "[role='combobox'] ~ [aria-hidden='true']"
    assert_no_css render_trigger, "[role='combobox'] ~ *"
  end

  def test_trailing_content_replaces_the_icon
    doc = render_trigger(icon_trailing: "chevron-down", trailing: -> { tag.button("Clear", type: "button") })

    assert_css doc, "[role='combobox'] ~ button", text: "Clear"
    assert_no_css doc, "[role='combobox'] ~ [aria-hidden='true']"
  end
end
