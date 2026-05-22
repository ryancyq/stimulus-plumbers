# frozen_string_literal: true

require "test_helper"

class ThemesConfigurationTest < Minitest::Test
  Configuration = StimulusPlumbers::Themes::Configuration
  Base          = StimulusPlumbers::Themes::Base

  def setup
    @config = Configuration.new
  end

  def test_current_returns_base_instance_by_default
    assert_instance_of Base, @config.current
  end

  def test_registry_starts_empty
    assert_empty @config.registry
  end

  def test_register_adds_theme_to_registry
    klass = Class.new(Base)
    @config.register(:custom, klass)

    assert_equal klass, @config.registry[:custom]
  end

  def test_register_raises_for_non_base_subclass
    assert_raises(ArgumentError) { @config.register(:bad, Class.new) }
  end

  def test_register_returns_self_for_chaining
    assert_equal @config, @config.register(:chained, Class.new(Base))
  end

  def test_use_by_name_switches_current
    klass = Class.new(Base)
    @config.register(:custom, klass)
    @config.use(:custom)

    assert_instance_of klass, @config.current
  end

  def test_use_with_instance_switches_current
    instance = Class.new(Base).new
    @config.use(instance)

    assert_equal instance, @config.current
  end

  def test_use_raises_for_unknown_name
    assert_raises(ArgumentError) { @config.use(:nonexistent) }
  end
end
