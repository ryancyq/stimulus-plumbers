# frozen_string_literal: true

require_relative "../../test_helper"

class ComponentManifestLoaderTest < Minitest::Test
  def test_reads_manifest_from_monorepo_dev_fallback
    result = StimulusPlumbers::MCP::ComponentManifestLoader.call

    assert_kind_of Hash, result
    assert result.key?("popover"), "expected the dev-fallback manifest built by earlier phases to include popover"
  end

  def test_returns_empty_hash_when_no_manifest_found
    StimulusPlumbers::MCP::ComponentManifestLoader.stub(:manifest_paths, ["/nonexistent/manifest.json"]) do
      assert_equal({}, StimulusPlumbers::MCP::ComponentManifestLoader.call)
    end
  end
end
