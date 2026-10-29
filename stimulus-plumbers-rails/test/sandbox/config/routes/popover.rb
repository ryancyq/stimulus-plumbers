# frozen_string_literal: true

scope "/popover", controller: "components" do
  get :combobox
  get "combobox/cities", action: "combobox_cities"
  get :search
  get "", action: "popover"
end
