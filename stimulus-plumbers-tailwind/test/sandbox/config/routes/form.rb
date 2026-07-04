# frozen_string_literal: true

scope "/form", controller: "form" do
  get :sign_up
  get :field_error
  get :fieldset
  get :choices
  get :floating_label
end
