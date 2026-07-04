# frozen_string_literal: true

scope "/display", controller: "components" do
  get :list
  get :ordered_list
  get :avatar
  get :icon
  get :timeline
end
