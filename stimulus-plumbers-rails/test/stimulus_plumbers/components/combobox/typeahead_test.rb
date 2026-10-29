# frozen_string_literal: true

require "test_helper"

class ComboboxTypeaheadTest < ActionView::TestCase
  def render_typeahead(**kwargs)
    parse_html(StimulusPlumbers::Components::Combobox::Typeahead.new(self).render(options: [%w[Canada ca]], **kwargs))
  end

  def test_renders_an_editable_combobox_with_a_text_input_control
    doc = render_typeahead(name: "city", value: "ca")

    assert_css doc, "[data-controller='combobox'][data-combobox-mode-value='editable']"
    assert_css doc, "input[type='text'][role='combobox'][value='Canada']"
    assert_css doc, "input[type='hidden'][name='city'][value='ca']"
  end

  def test_value_policy
    assert_css render_typeahead(value_policy: :freeform), "[data-combobox-value-policy-value='freeform']"
  end

  def test_source_and_param
    assert_css render_typeahead(id: "city", source: "/cities", param: :term),
               "[data-combobox-turbo-src-value='/cities'][data-combobox-turbo-param-value='term']"
  end

  def test_match_and_min_length
    assert_css render_typeahead(match: :fuzzy, min_length: 3),
               "[data-combobox-match-value='fuzzy'][data-combobox-min-length-value='3']"
  end
end
