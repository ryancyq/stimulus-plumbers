# frozen_string_literal: true

class ContainerComponentPreview < ViewComponent::Preview
  def default
    render ContainerComponent.new(tag: :section, aria: { label: "Main content" }) do
      "Container content"
    end
  end
end
