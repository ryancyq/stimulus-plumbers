# frozen_string_literal: true

class ApplicationController < ActionController::Base
  layout -> { request.path.start_with?("/a11y") ? "a11y" : "application" }
  helper StimulusPlumbers::Helpers
end
