# frozen_string_literal: true

Rails.application.routes.draw do
  scope "/components", controller: "components" do
    get :profile
    get :calendar
  end

  scope "/form", controller: "form" do
    get :sign_up
    get :field_error
  end
end
