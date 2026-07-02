# frozen_string_literal: true

require "test_helper"

class TailwindEngineTest < Minitest::Test
  def test_engine_is_a_rails_engine
    assert_operator StimulusPlumbers::Tailwind::Engine, :<, Rails::Engine
  end

  def test_engine_initializer_registers_and_activates_tailwind_theme
    with_reset_theme_current do
      initializer = StimulusPlumbers::Tailwind::Engine.initializers.find do |i|
        i.name == "stimulus_plumbers_tailwind.register_theme"
      end
      initializer.block.call

      assert_equal StimulusPlumbers::Themes::TailwindTheme, StimulusPlumbers.config.theme.registry[:tailwind]
      assert_instance_of StimulusPlumbers::Themes::TailwindTheme, StimulusPlumbers.config.theme.current
    end
  end

  def test_registers_theme_without_rails_engine
    without_rails_engine { load_tailwind_lib }

    assert_equal StimulusPlumbers::Themes::TailwindTheme, StimulusPlumbers.config.theme.registry[:tailwind]
  end

  def test_does_not_activate_theme_without_rails_engine
    without_rails_engine do
      with_reset_theme_current do
        load_tailwind_lib

        refute_instance_of StimulusPlumbers::Themes::TailwindTheme, StimulusPlumbers.config.theme.current
      end
    end
  end

  private

  # `@current` has no public reset — this is the one place that reaches into it,
  # so a renamed ivar breaks loudly here instead of silently in several tests.
  def with_reset_theme_current
    StimulusPlumbers.config.theme.instance_variable_set(:@current, nil)
    yield
  ensure
    StimulusPlumbers.config.theme.use(:tailwind)
  end

  def without_rails_engine
    rails_engine = Rails.send(:remove_const, :Engine)
    yield
  ensure
    Rails.const_set(:Engine, rails_engine)
  end

  def load_tailwind_lib
    load File.expand_path("../../../lib/stimulus_plumbers_tailwind.rb", __dir__)
  end
end
