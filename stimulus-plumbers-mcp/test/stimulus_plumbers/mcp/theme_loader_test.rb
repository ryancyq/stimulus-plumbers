# frozen_string_literal: true

require_relative "../../test_helper"

class ThemeLoaderTest < Minitest::Test
  def setup
    @data = StimulusPlumbers::MCP::ThemeLoader.call
  end

  def test_returns_hash_with_base_doc_and_components
    assert @data.key?(:base_doc)
    assert @data.key?(:components)
  end

  def test_base_doc_is_markdown_string
    assert_instance_of String, @data[:base_doc]
    assert_includes @data[:base_doc], "_classes"
    assert_includes @data[:base_doc], "StimulusPlumbers::Themes::Base"
    assert_includes @data[:base_doc], "config.theme.register"
  end

  def test_components_covers_all_schema_keys
    schema_keys = StimulusPlumbers::Themes::Base::SCHEMA.keys

    schema_keys.each do |key|
      assert @data[:components].key?(key), "Missing interface for schema key :#{key}"
    end
  end

  def test_button_interface_has_method_name
    assert_equal "button_classes", @data[:components][:button][:method]
  end

  def test_button_interface_has_returns_contract
    assert_equal "{ classes: String }", @data[:components][:button][:returns]
  end

  def test_button_interface_params_include_variant
    params = @data[:components][:button][:params]

    assert params.key?(:variant), "button interface missing :variant param"
    assert_includes params[:variant][:valid], :primary
    assert_includes params[:variant][:valid], :destructive
  end

  def test_button_interface_params_include_type_and_size
    params = @data[:components][:button][:params]

    assert params.key?(:type)
    assert params.key?(:size)
  end

  def test_param_less_components_are_included
    assert @data[:components].key?(:form_group), "form_group missing from interface"
    assert_equal "form_group_classes", @data[:components][:form_group][:method]
  end

  def test_all_components_have_required_keys
    @data[:components].each do |key, iface|
      assert iface.key?(:method),  "#{key} missing :method"
      assert iface.key?(:params),  "#{key} missing :params"
      assert iface.key?(:returns), "#{key} missing :returns"
    end
  end
end
