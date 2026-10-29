# frozen_string_literal: true

scope "/popover", controller: "components" do
  get :combobox
  get "combobox/cities", action: "combobox_cities"
  get :search
  get :fetch, action: "popover_fetch"
  get :menu, action: "popover_menu"
  get "", action: "popover"
end
