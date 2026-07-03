# frozen_string_literal: true

require_relative "../../test_helper"

class ComponentSchemaLoaderTest < Minitest::Test
  def setup
    @schema = StimulusPlumbers::MCP::ComponentSchemaLoader.call
  end

  def test_returns_components_field_as_and_controllers
    assert @schema.key?(:components)
    assert @schema.key?(:field_as)
    assert @schema.key?(:controllers)
  end

  def test_components_includes_core_keys
    %i[button button_group avatar card combobox_option].each do |key|
      assert @schema[:components].key?(key), "missing component key: #{key}"
    end
  end

  def test_button_has_expected_params
    button = @schema[:components][:button]

    assert button.key?(:type)
    assert button.key?(:variant)
    assert button.key?(:size)
  end

  def test_button_type_valid_values
    valid = @schema[:components][:button][:type][:valid]

    assert_includes valid, :default
    assert_includes valid, :outline
    assert_includes valid, :card
  end

  def test_button_variant_valid_values
    valid = @schema[:components][:button][:variant][:valid]

    assert_includes valid, :primary
    assert_includes valid, :destructive
  end

  def test_button_size_valid_values
    valid = @schema[:components][:button][:size][:valid]

    assert_includes valid, :sm
    assert_includes valid, :lg
  end

  def test_field_as_field_includes_text_and_date
    values = @schema[:field_as][:field]

    assert_includes values, :text
    assert_includes values, :date
    assert_includes values, :select
  end

  def test_field_as_choice_includes_radio_and_check_box
    values = @schema[:field_as][:choice]

    assert_includes values, :radio
    assert_includes values, :check_box
  end

  def test_controllers_is_a_hash_of_component_to_controllers
    assert_instance_of Hash, @schema[:controllers]
    refute_empty @schema[:controllers]
  end

  def test_field_as_controllers_maps_combobox_backed_as_values
    assert_equal "combobox-dropdown", @schema[:field_as_controllers][:select]
    assert_equal "combobox-date",     @schema[:field_as_controllers][:date]
  end

  def test_field_as_controllers_omits_plain_input_as_values
    refute @schema[:field_as_controllers].key?(:text), "text has no dedicated controller"
  end
end
