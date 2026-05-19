# frozen_string_literal: true

require "test_helper"

class TailwindThemeTest < Minitest::Test
  def setup
    @theme = StimulusPlumbers::Themes::TailwindTheme.new
  end

  def test_theme_name
    assert_equal "Tailwind", @theme.name
  end

  def test_resolves_all_known_components_without_error
    StimulusPlumbers::Themes::Base::SCHEMA.each_key do |component|
      result = @theme.resolve(component)

      assert_instance_of Hash, result, "expected Hash for #{component}"
    end
  end

  def test_registers_theme_without_rails_engine
    rails_engine = Rails.send(:remove_const, :Engine)
    load File.expand_path("../../../lib/stimulus_plumbers_tailwind.rb", __dir__)

    assert_equal StimulusPlumbers::Themes::TailwindTheme, StimulusPlumbers.config.theme.registry[:tailwind]
  ensure
    Rails.const_set(:Engine, rails_engine)
  end

  def test_loads_engine_with_rails_engine
    load File.expand_path("../../../lib/stimulus_plumbers_tailwind.rb", __dir__)

    assert_operator StimulusPlumbersTailwind::Engine, :<, Rails::Engine
  end
end
