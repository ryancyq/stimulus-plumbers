# frozen_string_literal: true

module KeyThemeHelper
  # Styles each key with its own sp-<key> class.
  def key_theme(keys)
    Class.new(StimulusPlumbers::Themes::Base) do
      keys.each { |key| define_method(:"#{key}_classes") { |**| { classes: "sp-#{key}" } } }
    end.new
  end
end
