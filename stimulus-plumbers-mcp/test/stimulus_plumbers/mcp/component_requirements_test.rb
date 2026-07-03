# frozen_string_literal: true

require_relative "../../test_helper"

class ComponentRequirementsTest < Minitest::Test
  def setup
    @requirements = StimulusPlumbers::MCP::ComponentRequirements.call
  end

  def test_returns_hash
    assert_instance_of Hash, @requirements
  end

  def test_combobox_controllers
    controllers = @requirements[:combobox]

    assert_includes controllers, "input-combobox"
    assert_includes controllers, "input-formatter"
  end

  def test_combobox_includes_nested_panel_controllers
    controllers = @requirements[:combobox]

    # Declared on nested sub-components (Combobox::Dropdown/Date/Time), not the top-level class
    assert_includes controllers, "combobox-dropdown"
    assert_includes controllers, "combobox-date"
    assert_includes controllers, "combobox-time"
  end

  def test_popover_controllers
    assert_includes @requirements[:popover], "popover"
  end

  def test_calendar_controllers
    controllers = @requirements[:calendar]

    assert_includes controllers, "calendar-month"
    assert_includes controllers, "calendar-year"
    assert_includes controllers, "calendar-decade"
    assert_includes controllers, "calendar-month-selector"
    assert_includes controllers, "calendar-year-selector"
    assert_includes controllers, "calendar-decade-selector"
  end

  def test_button_has_no_controllers
    assert_empty @requirements[:button]
  end

  def test_all_values_are_arrays
    @requirements.each do |component, controllers|
      assert_instance_of Array, controllers, "#{component} mapping is not an Array"
    end
  end

  def test_controller_identifiers_are_strings
    @requirements.each do |component, controllers|
      controllers.each do |id|
        assert_instance_of String, id, "Controller identifier in #{component} is not a String"
      end
    end
  end

  def test_no_duplicate_controllers_per_component
    @requirements.each do |component, controllers|
      assert_equal controllers.uniq, controllers, "#{component} has duplicate controller entries"
    end
  end
end
