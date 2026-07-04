# frozen_string_literal: true

Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  scope "/components" do
    draw :controls
    draw :display
    draw :layout
    draw :popover
    draw :calendar
    draw :showcase
  end

  draw :form
end
