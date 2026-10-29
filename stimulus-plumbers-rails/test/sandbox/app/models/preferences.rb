# frozen_string_literal: true

class Preferences
  include ActiveModel::Model

  attr_accessor :gender, :interests, :newsletter, :country, :role, :terms_of_service, :volume
end
