# frozen_string_literal: true

Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  scope "/components", controller: "components" do
    get :profile
    get :calendar_stimulus
    get :calendar_turbo
    get :combobox
    get :search
  end

  scope "/form", controller: "form" do
    get :sign_up
    get :field_error
  end

  scope "/a11y", as: "a11y" do
    scope "/components", controller: "components" do
      get :profile
      get :calendar_stimulus
      get :calendar_turbo
      get :combobox
      get :search
    end

    scope "/form", controller: "form" do
      get :sign_up
      get :field_error
    end
  end
end
