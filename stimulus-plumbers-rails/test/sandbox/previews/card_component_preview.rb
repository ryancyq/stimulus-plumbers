# frozen_string_literal: true

class CardComponentPreview < ViewComponent::Preview
  def default
    render CardComponent.new(title: "Card Title") { "Card content goes here." }
  end

  def with_sections
    component = CardComponent.new(title: "Sectioned Card")
    component.with_section(title: "Section One") { "First section content." }
    component.with_section(title: "Section Two") { "Second section content." }
    render component
  end
end
