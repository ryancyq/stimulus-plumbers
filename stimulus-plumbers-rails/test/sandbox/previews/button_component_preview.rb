# frozen_string_literal: true

class ButtonComponentPreview < ViewComponent::Preview
  def default
    render ButtonComponent.new { "Click me" }
  end

  def as_link
    render ButtonComponent.new(url: "/dashboard") { "Go to Dashboard" }
  end
end
