# frozen_string_literal: true

Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  scope "/components", controller: "components" do
    get :profile
    get :calendar_stimulus
    get :calendar_turbo
    get :combobox
    get :search
    get :button
    get :action_list
    get :card
    get :popover
  end

  scope "/form", controller: "form" do
    get :sign_up
    get :field_error
  end
end
