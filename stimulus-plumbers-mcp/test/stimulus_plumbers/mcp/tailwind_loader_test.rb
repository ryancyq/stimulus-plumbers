# frozen_string_literal: true

require_relative "../../test_helper"

class TailwindLoaderTest < Minitest::Test
  def setup
    @theme = StimulusPlumbers::MCP::TailwindLoader.call
  end

  def test_returns_hash
    assert_instance_of Hash, @theme
  end

  def test_button_key_present
    assert @theme.key?(:button), "Missing theme key :button"
  end

  def test_button_has_default
    assert @theme[:button].key?(:default), "button missing :default entry"
    refute_empty @theme[:button][:default], "button default classes are empty"
  end

  def test_button_has_variant_primary
    assert @theme[:button].key?("variant:primary"), "button missing variant:primary entry"
    refute_empty @theme[:button]["variant:primary"], "button variant:primary classes are empty"
  end

  def test_button_has_variant_destructive
    assert @theme[:button].key?("variant:destructive")
    refute_empty @theme[:button]["variant:destructive"]
  end

  def test_button_has_type_entries
    assert @theme[:button].key?("type:default")
    assert @theme[:button].key?("type:outline")
    assert @theme[:button].key?("type:card")
  end

  def test_no_nil_classes
    @theme.each do |key, variants|
      variants.each do |variant, classes|
        refute_nil classes, "#{key}/#{variant} returned nil classes"
      end
    end
  end

  def test_all_values_are_strings
    @theme.each do |key, variants|
      variants.each do |variant, classes|
        assert_instance_of String, classes, "#{key}/#{variant} classes is not a String"
      end
    end
  end

  def test_theme_keys_are_subset_of_schema
    schema_keys = StimulusPlumbers::Themes::Base::SCHEMA.keys

    @theme.each_key do |key|
      assert_includes schema_keys, key, "Theme key #{key} not in schema"
    end
  end

  def test_theme_covers_major_components
    %i[button link avatar combobox form_group].each do |key|
      assert @theme.key?(key), "Missing theme key :#{key}"
    end
  end
end
