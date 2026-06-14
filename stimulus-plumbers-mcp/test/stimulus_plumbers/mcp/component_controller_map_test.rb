# frozen_string_literal: true

require_relative "../../test_helper"

class ComponentControllerMapTest < Minitest::Test
  def setup
    @mapping = StimulusPlumbers::MCP::ComponentControllerMap.call
  end

  def test_returns_hash
    assert_instance_of Hash, @mapping
  end

  def test_combobox_controllers
    controllers = @mapping[:combobox]

    assert_includes controllers, "input-combobox"
    assert_includes controllers, "input-formatter"
  end

  def test_combobox_includes_nested_panel_controllers
    controllers = @mapping[:combobox]

    # Declared on nested sub-components (Combobox::Dropdown/Date/Time), not the top-level class
    assert_includes controllers, "combobox-dropdown"
    assert_includes controllers, "combobox-date"
    assert_includes controllers, "combobox-time"
  end

  def test_popover_controllers
    assert_includes @mapping[:popover], "popover"
  end

  def test_calendar_controllers
    controllers = @mapping[:calendar]

    assert_includes controllers, "calendar-month"
    assert_includes controllers, "calendar-observer"
  end

  def test_button_has_no_controllers
    assert_empty @mapping[:button]
  end

  def test_all_values_are_arrays
    @mapping.each do |component, controllers|
      assert_instance_of Array, controllers, "#{component} mapping is not an Array"
    end
  end

  def test_controller_identifiers_are_strings
    @mapping.each do |component, controllers|
      controllers.each do |id|
        assert_instance_of String, id, "Controller identifier in #{component} is not a String"
      end
    end
  end

  def test_no_duplicate_controllers_per_component
    @mapping.each do |component, controllers|
      assert_equal controllers.uniq, controllers, "#{component} has duplicate controller entries"
    end
  end
end
