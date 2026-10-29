# frozen_string_literal: true

require "test_helper"

class ComboboxDropdownTest < ActionView::TestCase
  def render_dropdown(**kwargs)
    parse_html(StimulusPlumbers::Components::Combobox::Dropdown.new(self).render(options: [%w[Canada ca]], **kwargs))
  end

  def test_renders_a_select_only_combobox_with_a_button_control
    doc = render_dropdown(name: "country", value: "ca")

    assert_css doc, "[data-controller='combobox'][data-combobox-mode-value='select_only']"
    assert_css doc, "button[role='combobox']", text: "Canada"
    assert_css doc, "input[type='hidden'][name='country'][value='ca']"
  end

  def test_rejects_a_value_policy
    assert_raises(ArgumentError) { render_dropdown(value_policy: :freeform) }
  end
end
