# frozen_string_literal: true

require "test_helper"

class ComboboxConfigTest < ActiveSupport::TestCase
  Config   = StimulusPlumbers::Components::Combobox::Config
  Combobox = StimulusPlumbers::Components::Combobox

  def test_no_variant_by_default
    config = Config.new

    assert_not config.selected?
    assert_nil config.renderer
  end

  def test_default_metadata_when_nothing_selected
    metadata = Config.new.metadata

    assert_equal "dialog", metadata.haspopup
    assert_equal "p1", metadata.popup_id_for("p1")
    assert_nil metadata.trigger_icon
    assert_empty metadata.trigger_options
    assert_empty metadata.stimulus_data("p1", {})
  end

  def test_variant_methods_return_nil
    config = Config.new

    assert_nil config.dropdown(options: [])
  end

  def test_dropdown_selects_dropdown_renderer
    config = Config.new
    config.dropdown(options: [])

    assert_predicate config, :selected?
    assert_equal Combobox::Dropdown, config.renderer
  end

  def test_last_variant_wins
    config = Config.new
    config.dropdown(options: [])
    config.date

    assert_equal Combobox::Date, config.renderer
  end

  def test_each_variant_type
    {
      typeahead: Combobox::Typeahead,
      date:      Combobox::Date,
      time:      Combobox::Time
    }.each do |method, klass|
      config = Config.new
      config.public_send(method)

      assert_equal klass, config.renderer
    end
  end

  def test_metadata_stimulus_data_uses_selected_options
    config = Config.new
    config.time(format: :h24)

    stimulus_data = config.metadata.stimulus_data("p1", config.options)

    assert_equal({ format: :h24 }.to_json, stimulus_data[:input_formatter_options_value])
  end
end
