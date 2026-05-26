# frozen_string_literal: true

require "test_helper"

class TailwindIconsExternalTest < Minitest::Test
  class TestSource
    include StimulusPlumbers::Themes::Tailwind::Icons::External

    def svg_path(_key) = ""
  end

  def source
    @source ||= TestSource.new
  end

  # ── parse_elements — group flattening ─────────────────────────────────────

  def test_parse_elements_flattens_g_group
    doc = REXML::Document.new('<svg><g><path d="M1 2"/></g></svg>')
    elements = source.send(:parse_elements, doc.root)

    assert_equal 1,     elements.size
    assert_equal :path, elements.first[:tag]
  end

  def test_parse_elements_flattens_nested_g_groups
    doc = REXML::Document.new('<svg><g><g><path d="M1 2"/></g></g></svg>')
    elements = source.send(:parse_elements, doc.root)

    assert_equal 1, elements.size
  end

  def test_parse_elements_collects_siblings_inside_g
    doc = REXML::Document.new('<svg><g><path d="M1 2"/><path d="M3 4"/></g></svg>')
    elements = source.send(:parse_elements, doc.root)

    assert_equal 2, elements.size
  end

  # ── parse_elements — hyphenated attributes ────────────────────────────────

  def test_parse_elements_maps_stroke_width_to_underscore_symbol
    doc = REXML::Document.new('<svg><path d="M1 2" stroke-width="2"/></svg>')
    elements = source.send(:parse_elements, doc.root)

    assert_equal "2", elements.first[:stroke_width]
  end

  def test_parse_elements_maps_stroke_linecap_to_underscore_symbol
    doc = REXML::Document.new('<svg><path d="M1 2" stroke-linecap="round"/></svg>')
    elements = source.send(:parse_elements, doc.root)

    assert_equal "round", elements.first[:stroke_linecap]
  end
end
