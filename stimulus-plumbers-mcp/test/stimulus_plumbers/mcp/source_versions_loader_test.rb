# frozen_string_literal: true

require_relative "../../test_helper"

class SourceVersionsLoaderTest < Minitest::Test
  def setup
    @versions = StimulusPlumbers::MCP::SourceVersionsLoader.call
  end

  def test_reports_a_version_for_each_gem_backed_source
    %i[schema docs theme tailwind].each do |key|
      assert_match(%r{\A\d+\.\d+\.\d+\z}, @versions.dig(key, :version), "expected a semver for #{key}")
    end
  end

  def test_reports_stimulus_version_and_resolution_path
    assert @versions.dig(:stimulus, :version), "expected a stimulus version"
    assert @versions.dig(:stimulus, :resolved_from), "expected a resolved_from path"
  end

  def test_reports_nil_stimulus_source_when_manifest_not_found
    StimulusPlumbers::MCP::StimulusManifestLoader.stub(:resolved_path, nil) do
      versions = StimulusPlumbers::MCP::SourceVersionsLoader.call

      assert_nil versions.dig(:stimulus, :version)
      assert_nil versions.dig(:stimulus, :resolved_from)
    end
  end
end
