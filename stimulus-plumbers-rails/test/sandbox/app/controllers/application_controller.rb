# frozen_string_literal: true

class ApplicationController < ActionController::Base
  layout "application"
  helper StimulusPlumbers::Helpers
end
