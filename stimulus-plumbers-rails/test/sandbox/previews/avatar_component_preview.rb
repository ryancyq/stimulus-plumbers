# frozen_string_literal: true

class AvatarComponentPreview < ViewComponent::Preview
  def with_name
    render AvatarComponent.new(name: "Jane Smith", initials: "JS")
  end

  def with_image
    render AvatarComponent.new(name: "John Doe", url: "https://example.com/avatar.jpg")
  end
end
