# frozen_string_literal: true

require "test_helper"
require "tempfile"
require_relative "../../../../lib/stimulus_plumbers/themes/icons/external"

class IconsExternalTest < Minitest::Test
  class TestSource
    include StimulusPlumbers::Themes::Icons::External

    def svg_path(_key)
      ""
    end
  end

  def source
    @source ||= TestSource.new
  end

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

  def test_fetch_maps_svg_root_aria_hidden_to_underscore_symbol
    with_svg_file('<svg aria-hidden="true"><path d="M1 2"/></svg>') do |src|
      assert_equal "true", src.fetch("icon")[:aria_hidden]
    end
  end

  def test_include_returns_false_when_file_missing
    refute_includes source, "missing"
  end

  def test_include_returns_true_when_file_exists
    with_svg_file('<svg viewBox="0 0 24 24"><path d="M1 2"/></svg>') do |src|
      assert_includes src, "icon"
    end
  end

  def test_fetch_returns_nil_when_file_missing
    assert_nil source.fetch("missing")
  end

  def test_fetch_returns_hash_when_file_exists
    with_svg_file('<svg viewBox="0 0 24 24"><path d="M1 2"/></svg>') do |src|
      assert_instance_of Hash, src.fetch("icon")
    end
  end

  def test_fetch_parses_svg_viewbox_attribute
    with_svg_file('<svg viewBox="0 0 24 24"><path d="M1 2"/></svg>') do |src|
      assert_equal "0 0 24 24", src.fetch("icon")[:view_box]
    end
  end

  def with_svg_file(content)
    Tempfile.open(["icon", ".svg"]) do |f|
      f.write(content)
      f.flush
      src = TestSource.new
      src.define_singleton_method(:svg_path) { |_| f.path }
      yield src
    end
  end
end
