# frozen_string_literal: true

scope "/calendar", controller: "components" do
  get "inline", action: "calendar_inline"
end
