# frozen_string_literal: true

class ActionListComponentPreview < ViewComponent::Preview
  def default
    component = ActionListComponent.new
    component.with_item { "First action" }
    component.with_item { "Second action" }
    render component
  end

  def with_sections
    component = ActionListComponent.new
    component.with_section(title: "Navigation") do |section|
      section.with_item(url: "/home") { "Home" }
      section.with_item(url: "/about") { "About" }
    end
    component.with_section(title: "Account") do |section|
      section.with_item { "Profile" }
      section.with_item { "Settings" }
    end
    render component
  end
end
