# frozen_string_literal: true

require_relative "../../test_helper"

class VersionsLoaderTest < Minitest::Test
  def setup
    @versions = StimulusPlumbers::MCP::VersionsLoader.call
  end

  def test_reports_a_version_for_each_gem_backed_source
    %i[component_schema component_docs component_theme tailwind icons component_guide tailwind_guide].each do |key|
      assert_match(%r{\A\d+\.\d+\.\d+\z}, @versions.dig(key, :version), "expected a semver for #{key}")
    end
  end

  def test_icons_versions_with_tailwind_gem_not_schema
    assert_equal @versions.dig(:tailwind, :version), @versions.dig(:icons, :version)
  end

  def test_component_guide_versions_with_component_schema_gem
    assert_equal @versions.dig(:component_schema, :version), @versions.dig(:component_guide, :version)
  end

  def test_tailwind_guide_versions_with_tailwind_gem
    assert_equal @versions.dig(:tailwind, :version), @versions.dig(:tailwind_guide, :version)
  end

  def test_reports_controller_schema_version_and_resolution_path
    assert @versions.dig(:controller_schema, :version), "expected a controller_schema version"
    assert @versions.dig(:controller_schema, :resolved_from), "expected a resolved_from path"
  end

  def test_reports_nil_controller_schema_source_when_manifest_not_found
    StimulusPlumbers::MCP::ControllerSchemaLoader.stub(:resolved_path, nil) do
      versions = StimulusPlumbers::MCP::VersionsLoader.call

      assert_nil versions.dig(:controller_schema, :version)
      assert_nil versions.dig(:controller_schema, :resolved_from)
    end
  end

  def test_reports_controller_docs_version_and_resolution_path
    assert @versions.dig(:controller_docs, :version), "expected a controller_docs version"
    assert @versions.dig(:controller_docs, :resolved_from), "expected a resolved_from path"
  end

  def test_reports_nil_controller_docs_source_when_dir_not_found
    StimulusPlumbers::MCP::ControllerDocsLoader.stub(:docs_dir, "/nonexistent") do
      versions = StimulusPlumbers::MCP::VersionsLoader.call

      assert_nil versions.dig(:controller_docs, :version)
      assert_nil versions.dig(:controller_docs, :resolved_from)
    end
  end

  def test_reports_controller_guide_version_and_resolution_path
    assert @versions.dig(:controller_guide, :version), "expected a controller_guide version"
    assert @versions.dig(:controller_guide, :resolved_from), "expected a resolved_from path"
  end

  def test_reports_nil_controller_guide_source_when_path_not_found
    StimulusPlumbers::MCP::GuideLoader.stub(:controller_guide_path, "/nonexistent") do
      versions = StimulusPlumbers::MCP::VersionsLoader.call

      assert_nil versions.dig(:controller_guide, :version)
      assert_nil versions.dig(:controller_guide, :resolved_from)
    end
  end
end
