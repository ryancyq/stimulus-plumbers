# frozen_string_literal: true

require_relative "../../test_helper"

class GemVendorPathTest < Minitest::Test
  def test_resolves_relative_segments_under_gem_vendor_dir
    path = StimulusPlumbers::MCP::GemVendorPath.resolve("controller", "docs")

    assert_match %r{/vendor/controller/docs\z}, path
  end

  def test_joins_multiple_segments
    path = StimulusPlumbers::MCP::GemVendorPath.resolve("controller", "docs", "modal.md")

    assert_match %r{/vendor/controller/docs/modal\.md\z}, path
  end

  def test_returns_nil_when_gem_is_not_installed
    Gem::Specification.stub(:find_by_name, ->(*) { raise Gem::MissingSpecError.new("stimulus_plumbers", "1.0") }) do
      assert_nil StimulusPlumbers::MCP::GemVendorPath.resolve("ARIA.md")
    end
  end
end
