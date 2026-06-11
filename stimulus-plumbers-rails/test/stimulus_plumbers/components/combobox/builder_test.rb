# frozen_string_literal: true

require "test_helper"

class ComboboxBuilderTest < ActiveSupport::TestCase
  Builder  = StimulusPlumbers::Components::Combobox::Builder
  Combobox = StimulusPlumbers::Components::Combobox

  def test_no_variant_by_default
    builder = Builder.new

    assert_not builder.selected?
    assert_nil builder.renderer
  end

  def test_default_metadata_when_nothing_selected
    metadata = Builder.new.metadata

    assert_equal "dialog", metadata.haspopup
    assert_equal "p1", metadata.popup_id_for("p1")
    assert_nil metadata.trigger_icon
    assert_empty metadata.trigger_options
    assert_empty metadata.dataset("p1", {})
  end

  def test_variant_methods_return_nil
    builder = Builder.new

    assert_nil builder.dropdown(options: [])
  end

  def test_dropdown_selects_dropdown_renderer
    builder = Builder.new
    builder.dropdown(options: [])

    assert_predicate builder, :selected?
    assert_equal Combobox::Dropdown, builder.renderer
  end

  def test_last_variant_wins
    builder = Builder.new
    builder.dropdown(options: [])
    builder.date

    assert_equal Combobox::Date, builder.renderer
  end

  def test_each_variant_type
    {
      typeahead: Combobox::Typeahead,
      date:      Combobox::Date,
      time:      Combobox::Time
    }.each do |method, klass|
      builder = Builder.new
      builder.public_send(method)

      assert_equal klass, builder.renderer
    end
  end

  def test_metadata_dataset_uses_selected_options
    builder = Builder.new
    builder.time(format: :h24)

    dataset = builder.metadata.dataset("p1", builder.options)

    assert_equal({ format: :h24 }.to_json, dataset[:input_formatter_options_value])
  end
end
