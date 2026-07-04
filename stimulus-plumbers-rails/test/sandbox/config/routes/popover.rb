# frozen_string_literal: true

scope "/popover", controller: "components" do
  get :combobox
  get :search
  get "", action: "popover"
end
