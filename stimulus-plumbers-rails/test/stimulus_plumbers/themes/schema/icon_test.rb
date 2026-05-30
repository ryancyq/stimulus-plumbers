# frozen_string_literal: true

require "test_helper"

class SchemaIconTest < Minitest::Test
  Icon = StimulusPlumbers::Themes::Schema::Icon

  def test_svg_defaults_includes_container_attributes
    assert_includes Icon::SVG_ATTR_DEFAULTS, :xmlns
    assert_includes Icon::SVG_ATTR_DEFAULTS, :fill
    assert_includes Icon::SVG_ATTR_DEFAULTS, :view_box
    assert_includes Icon::SVG_ATTR_DEFAULTS, :width
    assert_includes Icon::SVG_ATTR_DEFAULTS, :height
    assert_includes Icon::SVG_ATTR_DEFAULTS, :stroke
    assert_includes Icon::SVG_ATTR_DEFAULTS, :stroke_width
  end

  def test_svg_defaults_does_not_include_element_attributes
    refute_includes Icon::SVG_ATTR_DEFAULTS, :d
    refute_includes Icon::SVG_ATTR_DEFAULTS, :stroke_linecap
    refute_includes Icon::SVG_ATTR_DEFAULTS, :stroke_linejoin
    refute_includes Icon::SVG_ATTR_DEFAULTS, :elements
  end

  def test_svg_attr_names_renames_view_box_to_viewbox
    assert_equal "viewBox", Icon::SVG_ATTR_NAMES[:view_box]
  end

  def test_svg_attr_names_renames_stroke_width_to_hyphenated
    assert_equal "stroke-width", Icon::SVG_ATTR_NAMES[:stroke_width]
  end

  def test_element_attr_names_renames_all_hyphenated_keys
    assert_equal "fill-rule",       Icon::ELEMENT_ATTR_NAMES[:fill_rule]
    assert_equal "clip-rule",       Icon::ELEMENT_ATTR_NAMES[:clip_rule]
    assert_equal "stroke-width",    Icon::ELEMENT_ATTR_NAMES[:stroke_width]
    assert_equal "stroke-linecap",  Icon::ELEMENT_ATTR_NAMES[:stroke_linecap]
    assert_equal "stroke-linejoin", Icon::ELEMENT_ATTR_NAMES[:stroke_linejoin]
  end

  def test_element_attrs_are_keyed_by_tag
    assert_includes Icon::ELEMENT_ATTRS, :path
    assert_includes Icon::ELEMENT_ATTRS, :circle
    assert_includes Icon::ELEMENT_ATTRS, :ellipse
    assert_includes Icon::ELEMENT_ATTRS, :rect
    assert_includes Icon::ELEMENT_ATTRS, :line
    assert_includes Icon::ELEMENT_ATTRS, :polyline
    assert_includes Icon::ELEMENT_ATTRS, :polygon
  end

  def test_path_element_attrs
    assert_includes Icon::ELEMENT_ATTRS[:path], :d
    assert_includes Icon::ELEMENT_ATTRS[:path], :fill
    assert_includes Icon::ELEMENT_ATTRS[:path], :fill_rule
    assert_includes Icon::ELEMENT_ATTRS[:path], :clip_rule
    assert_includes Icon::ELEMENT_ATTRS[:path], :stroke_linecap
    assert_includes Icon::ELEMENT_ATTRS[:path], :stroke_linejoin
    assert_includes Icon::ELEMENT_ATTRS[:path], :opacity
  end

  def test_resolve_returns_nil_for_nil_input
    assert_nil Icon.resolve(nil)
  end

  def test_resolve_returns_nil_when_elements_absent
    assert_nil Icon.resolve({})
  end

  def test_resolve_returns_nil_when_elements_empty
    assert_nil Icon.resolve({ elements: [] })
  end

  def test_resolve_returns_nil_when_all_elements_have_unknown_tags
    assert_nil Icon.resolve({ elements: [{ tag: :unknown, d: "M1 2" }] })
  end

  def test_resolve_returns_hash_with_valid_elements
    result = Icon.resolve({ elements: [{ tag: :path, d: "M1 2 3 4" }] })

    assert_instance_of Hash, result
  end

  def test_resolve_elements_preserve_tag_and_attrs
    result = Icon.resolve({ elements: [{ tag: :path, d: "M1 2 3 4" }] })
    el = result[:elements].first

    assert_equal :path, el[:tag]
    assert_equal "M1 2 3 4", el["d"]
  end

  def test_resolve_filters_elements_with_unknown_tags
    result = Icon.resolve({ elements: [{ tag: :path, d: "M1 2" }, { tag: :unknown, d: "M3 4" }] })

    assert_equal 1,     result[:elements].size
    assert_equal :path, result[:elements].first[:tag]
  end

  def test_resolve_strips_unknown_element_attrs
    result = Icon.resolve({ elements: [{ tag: :path, d: "M1 2", unknown: "ignored" }] })

    refute_includes result[:elements].first, "unknown"
  end

  def test_resolve_applies_svg_defaults
    result = Icon.resolve({ elements: [{ tag: :path, d: "M1 2" }] })

    assert_equal "http://www.w3.org/2000/svg", result["xmlns"]
    assert_equal "none",                       result["fill"]
    assert_equal "0 0 24 24", result["viewBox"]
    assert_equal "24",                         result["width"]
    assert_equal "24",                         result["height"]
    assert_equal "currentColor",               result["stroke"]
    assert_equal "1.5",                        result["stroke-width"]
  end

  def test_resolve_overrides_svg_defaults
    result = Icon.resolve({ fill: "red", stroke_width: 2, elements: [{ tag: :path, d: "M1 2" }] })

    assert_equal "red", result["fill"]
    assert_equal "2",   result["stroke-width"]
  end

  def test_resolve_strips_unknown_svg_attrs
    result = Icon.resolve({ unknown: "ignored", elements: [{ tag: :path, d: "M1 2" }] })

    refute_includes result, "unknown"
  end

  def test_resolve_coerces_svg_attr_values_to_strings
    result = Icon.resolve({ stroke_width: 2, elements: [{ tag: :path, d: "M1 2" }] })

    assert_equal "2", result["stroke-width"]
    result.except(:elements).each_value { |v| assert_instance_of String, v }
  end

  def test_resolve_coerces_element_attr_values_to_strings
    result = Icon.resolve({ elements: [{ tag: :path, d: "M1 2", stroke_linecap: :round }] })

    assert_equal "round", result[:elements].first["stroke-linecap"]
  end

  def test_resolve_passes_through_linecap_and_linejoin
    result = Icon.resolve({ elements: [{ tag: :path, d: "M1 2", stroke_linecap: :round, stroke_linejoin: :round }] })
    el = result[:elements].first

    assert_equal "round", el["stroke-linecap"]
    assert_equal "round", el["stroke-linejoin"]
  end

  def test_resolve_omits_linecap_and_linejoin_when_not_provided
    result = Icon.resolve({ elements: [{ tag: :path, d: "M1 2" }] })
    el = result[:elements].first

    refute_includes el, "stroke-linecap"
    refute_includes el, "stroke-linejoin"
  end

  def test_resolve_passes_through_fill_on_path_element
    result = Icon.resolve({ elements: [{ tag: :path, d: "M1 2", fill: "currentColor" }] })

    assert_equal "currentColor", result[:elements].first["fill"]
  end

  def test_resolve_passes_through_opacity_on_path_element
    result = Icon.resolve({ elements: [{ tag: :path, d: "M1 2", opacity: "0.25" }] })

    assert_equal "0.25", result[:elements].first["opacity"]
  end
end
