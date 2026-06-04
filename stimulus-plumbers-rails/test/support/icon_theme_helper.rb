# frozen_string_literal: true

module IconThemeHelper
  def with_icon_theme(&block)
    StimulusPlumbers.config.theme.stub(:current, stub_icon_theme, &block)
  end

  def stub_icon_theme
    Class.new(StimulusPlumbers::Themes::Base) do
      def icons
        Hash.new { { elements: [{ tag: :path, d: "M0 0" }] } }
      end
    end.new
  end
end
