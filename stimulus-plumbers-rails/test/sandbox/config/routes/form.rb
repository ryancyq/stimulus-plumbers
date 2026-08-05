# frozen_string_literal: true

scope "/form", controller: "form" do
  get :sign_up
  get :field_error
  get :fieldset
  get :choices
  get :floating_label
  get :code
  get :credit_card
  get :password
  get :progress
  get :range
end
