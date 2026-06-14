# frozen_string_literal: true

require_relative "../../test_helper"

class StimulusManifestTest < Minitest::Test
  EXPECTED_IDENTIFIERS = %w[
    calendar-month calendar-observer clipboard combobox-date combobox-dropdown
    combobox-time dismisser flipper input-clearable input-combobox input-formatter
    modal panner popover visibility
  ].freeze

  def setup
    @controllers = StimulusPlumbers::MCP::StimulusManifest.call
  end

  def test_all_expected_controllers_present
    EXPECTED_IDENTIFIERS.each do |id|
      assert @controllers.key?(id), "Missing controller: #{id}"
    end
  end

  def test_controller_count
    assert_equal EXPECTED_IDENTIFIERS.size, @controllers.size
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

  def test_popover_classes
    assert_includes @controllers["popover"]["classes"], "hidden"
  end

  def test_combobox_date_outlets
    assert_includes @controllers["combobox-date"]["outlets"], "calendar-month"
  end

  def test_each_controller_has_required_keys
    @controllers.each do |id, data|
      %w[identifier targets values outlets classes].each do |key|
        assert data.key?(key), "Controller #{id} missing key: #{key}"
      end
      assert_equal id, data["identifier"], "Controller #{id} has wrong identifier"
    end
  end
end
