# frozen_string_literal: true

class StubThemeTestCase < Minitest::Test
  def setup
    @theme = build_stub_theme
  end

  def build_stub_theme
    Class.new(StimulusPlumbers::Themes::Base) do
      private

      StimulusPlumbers::Themes::Base::SCHEMA.each_key do |component|
        define_method(:"#{component}_classes") { |**| {} }
      end
    end.new
  end
end
