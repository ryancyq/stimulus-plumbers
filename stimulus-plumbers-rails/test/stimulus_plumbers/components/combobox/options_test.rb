# frozen_string_literal: true

require "test_helper"

class ComboboxOptionsTest < ActionView::TestCase
  def render_options(items = [], value: nil, &block)
    StimulusPlumbers::Components::Combobox::Options.new(self).render(items, value: value, &block)
  end

  # ── array tuple ───────────────────────────────────────────────────────────

  def test_renders_option_from_array_tuple
    doc = parse_html(render_options([["United States", "us"]]))

    assert_css doc, "li[role='option'][data-value='us']"
  end

  def test_renders_option_from_array_tuple_with_attrs
    doc = parse_html(render_options([["Disabled", "x", { disabled: true }]]))

    assert_css doc, "li[role='option'][data-value='x'][aria-disabled='true']"
  end

  # ── hash option ───────────────────────────────────────────────────────────

  def test_renders_option_from_hash
    doc = parse_html(render_options([{ label: "Canada", value: "ca" }]))

    assert_css doc, "li[role='option'][data-value='ca']"
  end

  def test_renders_option_from_hash_with_description
    doc    = parse_html(render_options([{ label: "Canada", value: "ca", description: "North America" }]))
    option = doc.at_css("li[role='option'][data-value='ca']")

    assert_not_nil option
    assert_equal 2, option.css("span").length
  end

  # ── optgroup ──────────────────────────────────────────────────────────────

  def test_renders_optgroup_from_hash_with_options_key
    items = [{ label: "Americas", options: [["United States", "us"]] }]
    doc   = parse_html(render_options(items))

    assert_css doc, "li[role='group'][aria-label='Americas']"
    assert_css doc, "li[role='group'] li[role='option'][data-value='us']"
  end

  def test_optgroup_nested_options_inherit_selected_value
    items = [{ label: "Americas", options: [["Canada", "ca"], ["United States", "us"]] }]
    doc   = parse_html(render_options(items, value: "ca"))

    assert_css doc, "li[role='group'] li[data-value='ca'][aria-selected='true']"
    assert_css doc, "li[role='group'] li[data-value='us'][aria-selected='false']"
  end

  # ── selection ─────────────────────────────────────────────────────────────

  def test_marks_matching_option_as_selected
    doc = parse_html(render_options([["Canada", "ca"], ["United States", "us"]], value: "ca"))

    assert_css doc, "li[role='option'][data-value='ca'][aria-selected='true']"
    assert_css doc, "li[role='option'][data-value='us'][aria-selected='false']"
  end

  def test_no_option_selected_when_value_is_nil
    doc = parse_html(render_options([%w[Canada ca]]))

    assert_no_css doc, "li[aria-selected='true']"
  end

  # ── unknown type ──────────────────────────────────────────────────────────

  def test_skips_unknown_item_type_and_logs_warning
    mock_logger = Minitest::Mock.new
    mock_logger.expect(:warn, nil, [%r{unrecognized item type Integer}])

    Rails.stub(:logger, mock_logger) do
      result = render_options([42])

      assert_equal "", result
    end

    mock_logger.verify
  end

  # ── block override ────────────────────────────────────────────────────────

  def test_block_overrides_option_rendering
    doc = parse_html(
      render_options([%w[Canada ca]]) { |attrs| "<custom>#{attrs[:label]}</custom>".html_safe }
    )

    assert_includes doc.to_html, "<custom>Canada</custom>"
    assert_no_css doc, "li[role='option']"
  end

  def test_block_overrides_optgroup_rendering
    items = [{ label: "Americas", options: [%w[US us]] }]
    doc   = parse_html(
      render_options(items) do |attrs|
        attrs.key?(:optgroup) ? "<g>#{attrs[:optgroup][:label]}</g>".html_safe : "".html_safe
      end
    )

    assert_includes doc.to_html, "<g>Americas</g>"
    assert_no_css doc, "li[role='group']"
  end
end
