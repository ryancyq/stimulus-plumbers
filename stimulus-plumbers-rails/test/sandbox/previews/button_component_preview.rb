# frozen_string_literal: true

class ButtonComponentPreview < ViewComponent::Preview
  def default
    render ButtonComponent.new do
      "Click me"
    end
  end

  def as_link
    render ButtonComponent.new(url: "/dashboard") do
      "Go to Dashboard"
    end
  end
end
