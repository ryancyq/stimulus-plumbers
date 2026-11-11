# frozen_string_literal: true

require_relative "../../test_helper"

class ControllerSchemaLoaderTest < Minitest::Test
  EXPECTED_IDENTIFIERS = %w[
    calendar calendar-turbo
    combobox combobox-turbo combobox-fetch combobox-date combobox-time
    input-clearable input-formatter input-revealable
    checklist clipboard reorderable progress timeline dismisser flipper
    modal modal-turbo panner password-strength popover popover-fetch visibility
  ].freeze

  def setup
    @controllers = StimulusPlumbers::MCP::ControllerSchemaLoader.call
  end

  def test_all_expected_controllers_present
    EXPECTED_IDENTIFIERS.each do |id|
      assert @controllers.key?(id), "Missing controller: #{id}"
    end
  end

  def test_controllers
    assert_equal EXPECTED_IDENTIFIERS.sort, @controllers.keys.sort
  end

  def test_modal_targets
    assert_equal ["dialog"], @controllers["modal"]["targets"]
  end

  def test_modal_has_no_values
    assert_empty @controllers["modal"]["values"]
  end

  def test_combobox_targets
    assert_equal %w[trigger input panel listbox status], @controllers["combobox"]["targets"]
  end

  def test_combobox_values
    values = @controllers["combobox"]["values"]

    assert_equal "String", values["mode"]["type"]
    assert_equal "select_only", values["mode"]["default"]
    assert_equal "Number", values["minLength"]["type"]
    assert_equal 1, values["minLength"]["default"]
  end

  def test_combobox_close_on_select_value
    close_on_select = @controllers["combobox"]["values"]["closeOnSelect"]

    assert_equal "Boolean", close_on_select["type"]
    assert close_on_select["default"]
  end

  def test_outlets
    assert_includes @controllers["combobox-date"]["outlets"], "calendar"
  end

  def test_combobox_date_targets
    assert_equal %w[trigger input panel], @controllers["combobox-date"]["targets"]
  end

  def test_each_controller_has_required_keys
    @controllers.each do |id, data|
      %w[identifier targets values outlets classes].each do |key|
        assert data.key?(key), "Controller #{id} missing key: #{key}"
      end
      assert_equal id, data["identifier"], "Controller #{id} has wrong identifier"
    end
  end

  def test_merges_wiring_from_component_manifest
    popover = StimulusPlumbers::MCP::ControllerSchemaLoader.call["popover"]

    assert popover.key?("wiring"), "expected controller schema to include a wiring key"
    assert_includes popover["wiring"]["actions"], "open"
  end

  def test_wiring_defaults_to_empty_when_ruby_never_references_a_controller
    ctrl = StimulusPlumbers::MCP::ControllerSchemaLoader.call["flipper"]

    assert_equal({ "actions" => [], "listens" => [], "targets" => [], "values" => [] }, ctrl["wiring"])
  end

  def test_returns_empty_hash_when_no_manifest_found
    StimulusPlumbers::MCP::ControllerSchemaLoader.stub(
      :manifest_paths,
      ["/nonexistent/a.json", "/nonexistent/b.json", "/nonexistent/c.json"]
    ) do
      result = StimulusPlumbers::MCP::ControllerSchemaLoader.call

      assert_equal({}, result)
    end
  end
end
