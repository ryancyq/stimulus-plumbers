# frozen_string_literal: true

scope "/calendar", controller: "components" do
  get "stimulus", action: "calendar_stimulus"
  get "turbo", action: "calendar_turbo"
end
