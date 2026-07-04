# frozen_string_literal: true

require_relative "../../test_helper"

class ControllerSchemaLoaderTest < Minitest::Test
  EXPECTED_IDENTIFIERS = %w[
    calendar-decade calendar-decade-selector
    calendar-month calendar-month-selector
    calendar-year calendar-year-selector
    combobox-date combobox-time combobox-dropdown
    input-clearable input-combobox input-formatter
    clipboard reorderable timeline dismisser flipper
    modal panner popover visibility
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
    modal = @controllers["modal"]

    assert_includes modal["targets"], "modal"
    assert_includes modal["targets"], "overlay"
  end

  def test_modal_has_no_values
    assert_empty @controllers["modal"]["values"]
  end

  def test_input_combobox_targets
    ctrl = @controllers["input-combobox"]

    assert_includes ctrl["targets"], "trigger"
    assert_includes ctrl["targets"], "input"
  end

  def test_input_combobox_values
    values = @controllers["input-combobox"]["values"]

    assert values.key?("value"), "Missing value key 'value'"
    assert_equal "String", values["value"]["type"]
    assert values.key?("minLength"), "Missing value key 'minLength'"
    assert_equal "Number", values["minLength"]["type"]
    assert_equal 1, values["minLength"]["default"]
  end

  def test_input_combobox_outlets
    assert_includes @controllers["input-combobox"]["outlets"], "combobox-dropdown"
  end

  def test_popover_values_include_defaults
    values = @controllers["popover"]["values"]

    assert_equal "never", values["reload"]["default"]
    assert_equal 3600, values["staleAfter"]["default"]
    assert values["closeOnSelect"]["default"]
  end

  def test_combobox_date_outlets
    assert_includes @controllers["combobox-date"]["outlets"], "calendar-month"
    assert_includes @controllers["combobox-date"]["outlets"], "calendar-year"
    assert_includes @controllers["combobox-date"]["outlets"], "calendar-decade"
  end

  def test_each_controller_has_required_keys
    @controllers.each do |id, data|
      %w[identifier targets values outlets classes].each do |key|
        assert data.key?(key), "Controller #{id} missing key: #{key}"
      end
      assert_equal id, data["identifier"], "Controller #{id} has wrong identifier"
    end
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
