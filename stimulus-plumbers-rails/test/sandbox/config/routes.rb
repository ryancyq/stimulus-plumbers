# frozen_string_literal: true

Rails.application.routes.draw do
  mount ViewComponent::Engine, at: "/"

  scope "/form", controller: "form" do
    get :sign_in
    get :text_fields
    get :password_field
    get :textarea
    get :choice_fields
    get :select_field
    get :field_states
  end
end
