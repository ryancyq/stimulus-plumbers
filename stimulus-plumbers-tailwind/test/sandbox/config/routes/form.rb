# frozen_string_literal: true

scope "/form", controller: "form" do
  get :sign_up
  get :field_error
  get :fieldset
  get :floating_label
  get :choices
  get :single_checkbox
  get :collection_checkbox
  get :collection_radio
  get :code
  get :credit_card
  get :password
  get :progress
  get :range
end
