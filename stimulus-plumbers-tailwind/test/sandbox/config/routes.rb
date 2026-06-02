# frozen_string_literal: true

Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  scope "/components", controller: "components" do
    get :profile
    get :calendar_stimulus
    get :calendar_turbo
    get :combobox
    get :search
    get :action_list
    get :avatar
    get :button
    get :card
    get :link
    get :divider
    get :popover
  end

  scope "/form", controller: "form" do
    get :sign_up
    get :field_error
    get :fieldset
    get :choices
    get :floating_label
  end
end
