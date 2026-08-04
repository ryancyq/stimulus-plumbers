# frozen_string_literal: true

class Preferences
  include ActiveModel::Model

  attr_accessor :gender, :interests, :newsletter
end
