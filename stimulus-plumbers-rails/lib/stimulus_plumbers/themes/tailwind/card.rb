# frozen_string_literal: true

module StimulusPlumbers::Themes::Tailwind::Card
  BASE = %w[
    rounded-[--sp-radius-lg] border border-[--sp-color-border]
    bg-[--sp-color-bg] shadow-[--sp-shadow-sm]
  ].freeze

  private

  def card_classes
    { classes: klasses(*BASE) }
  end

  def card_section_classes
    { classes: klasses("p-[--sp-space-6]") }
  end
end
