# frozen_string_literal: true

require "test_helper"

class ConfigurationTest < Minitest::Test
  def setup
    @config = StimulusPlumbers::Configuration.new
  end

  def test_configure_yields_config_object
    yielded = nil
    StimulusPlumbers.configure { |c| yielded = c }

    assert_same StimulusPlumbers.config, yielded
  end

  def test_theme_returns_a_theme_configuration
    assert_instance_of StimulusPlumbers::Themes::Configuration, @config.theme
  end

  def test_theme_is_memoized
    assert_same @config.theme, @config.theme
  end

  def test_theme_current_defaults_to_a_base_instance
    assert_instance_of StimulusPlumbers::Themes::Base, @config.theme.current
  end

  def test_theme_current_is_memoized
    assert_same @config.theme.current, @config.theme.current
  end

  def test_theme_register_accepts_a_base_subclass
    custom_klass = Class.new(StimulusPlumbers::Themes::Base)
    @config.theme.register(:custom, custom_klass)

    assert_equal custom_klass, @config.theme.registry[:custom]
  end

  def test_theme_register_accepts_base_itself
    @config.theme.register(:custom, StimulusPlumbers::Themes::Base)

    assert_equal StimulusPlumbers::Themes::Base, @config.theme.registry[:custom]
  end

  def test_theme_register_raises_for_a_non_base_subclass
    err = assert_raises(ArgumentError) { @config.theme.register(:bad, Class.new) }

    assert_match %r{must be a subclass of Themes::Base}, err.message
  end

  def test_theme_register_is_chainable
    result = @config.theme.register(:custom, Class.new(StimulusPlumbers::Themes::Base))

    assert_same @config.theme, result
  end

  def test_theme_use_accepts_a_registered_name
    custom_klass = Class.new(StimulusPlumbers::Themes::Base)
    @config.theme.register(:custom, custom_klass)
    @config.theme.use(:custom)

    assert_instance_of custom_klass, @config.theme.current
  end

  def test_theme_use_accepts_a_themes_base_instance_directly
    custom = StimulusPlumbers::Themes::Base.new
    @config.theme.use(custom)

    assert_same custom, @config.theme.current
  end

  def test_theme_use_raises_for_an_unknown_name
    err = assert_raises(ArgumentError) { @config.theme.use(:unknown) }

    assert_match %r{Unknown theme :unknown}, err.message
    assert_match %r{Registered:}, err.message
  end

  def test_theme_use_is_chainable
    result = @config.theme.use(StimulusPlumbers::Themes::Base.new)

    assert_same @config.theme, result
  end

  def test_log_formatter_defaults_to_the_built_in_prefix_formatter
    assert_equal "[StimulusPlumbers] hello", @config.log_formatter.call("hello")
  end

  def test_log_formatter_is_memoized
    assert_same @config.log_formatter, @config.log_formatter
  end

  def test_log_formatter_setter_accepts_any_callable
    @config.log_formatter = ->(msg) { "PREFIX: #{msg}" }

    assert_equal "PREFIX: test", @config.log_formatter.call("test")
  end

  def test_log_formatter_setter_accepts_a_proc
    @config.log_formatter = proc(&:upcase)

    assert_equal "TEST", @config.log_formatter.call("test")
  end

  def test_log_formatter_setter_raises_argument_error_when_given_a_non_callable
    err = assert_raises(ArgumentError) { @config.log_formatter = "a string" }

    assert_match %r{respond to #call}, err.message
  end

  def test_log_formatter_setter_raises_argument_error_when_given_nil
    err = assert_raises(ArgumentError) { @config.log_formatter = nil }

    assert_match %r{respond to #call}, err.message
  end
end
