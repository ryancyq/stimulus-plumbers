# frozen_string_literal: true

class PopoverComponentPreview < ViewComponent::Preview
  def default
    component = PopoverComponent.new(interactive: true)
    component.with_activator { "Open menu" }
    render component do
      "Popover content"
    end
  end

  def static
    render PopoverComponent.new(interactive: false) do
      "Static popover content"
    end
  end
end
