# frozen_string_literal: true

require "test_helper"

class PlumberConfigTest < ActiveSupport::TestCase
  # The store is private, so the base is exercised the way real Config DSLs use it:
  # a subclass with a named setter and named readers.
  class StrengthConfig < StimulusPlumbers::Plumber::Config
    def strength(**options)
      configure(:strength, options)
    end

    def disable_strength
      configure(:strength, nil)
    end

    def strength_options
      config(:strength)
    end

    def strength?
      configured?(:strength)
    end
  end

  def setup
    @config = StrengthConfig.new
  end

  def test_setter_returns_nil_so_it_reads_as_a_command
    assert_nil @config.strength(min_length: 12)
  end

  def test_reader_returns_the_configured_value
    @config.strength(min_length: 12)

    assert_equal({ min_length: 12 }, @config.strength_options)
  end

  def test_reader_returns_nil_when_never_configured
    assert_nil @config.strength_options
  end

  def test_last_write_wins
    @config.strength(min_length: 8)
    @config.strength(min_length: 12)

    assert_equal({ min_length: 12 }, @config.strength_options)
  end

  def test_predicate_distinguishes_unconfigured_from_configured_nil
    refute_predicate @config, :strength?

    @config.disable_strength

    assert_predicate @config, :strength?
    assert_nil @config.strength_options
  end

  def test_template_is_exposed_for_renderers
    template = Object.new

    assert_same template, StrengthConfig.new(template).template
  end

  def test_building_without_a_template_does_not_raise
    assert_nil @config.template
  end

  def test_the_store_is_not_public_api
    assert_raises(NoMethodError) { @config.configure(:strength, {}) }
    assert_raises(NoMethodError) { @config.config(:strength) }
    assert_raises(NoMethodError) { @config.configured?(:strength) }
  end
end
