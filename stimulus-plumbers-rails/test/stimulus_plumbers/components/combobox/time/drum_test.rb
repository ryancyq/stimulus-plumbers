# frozen_string_literal: true

require "test_helper"

class ComboboxTimeDrumTest < ActionView::TestCase
  def renderer
    StimulusPlumbers::Components::Combobox::Time::Drum.new(self)
  end

  def render_drum(items: [%w[12 12], %w[1 1]], selected: nil)
    renderer.render(
      stimulus_controller: "combobox-time",
      target:              "hours",
      label:               "Hours",
      items:               items,
      selected:            selected
    )
  end

  def test_renders_ul_with_listbox_role
    assert_css parse_html(render_drum), "ul[role='listbox']"
  end

  def test_has_tabindex_zero
    assert_css parse_html(render_drum), "ul[tabindex='0']"
  end

  def test_has_aria_label
    assert_css parse_html(render_drum), "ul[aria-label='Hours']"
  end

  def test_sets_stimulus_target
    assert_css parse_html(render_drum), "ul[data-combobox-time-target='hours']"
  end

  def test_has_click_action
    assert_includes render_drum, "click-&gt;combobox-time#select"
  end

  def test_has_keydown_navigate_action
    assert_includes render_drum, "keydown-&gt;combobox-time#onNavigate"
  end

  def test_renders_option_for_each_item
    doc = parse_html(render_drum(items: [%w[12 12], %w[1 1], %w[2 2]]))

    assert_equal 3, doc.css("li[role='option']").length
  end

  def test_marks_selected_item
    doc = parse_html(render_drum(items: [%w[12 12], %w[1 1]], selected: "12"))

    assert_css doc, "li[data-value='12'][aria-selected='true']"
    assert_css doc, "li[data-value='1'][aria-selected='false']"
  end

  def test_no_item_selected_when_selected_nil
    doc = parse_html(render_drum(items: [%w[12 12]]))

    assert_no_css doc, "li[aria-selected='true']"
  end
end
