# frozen_string_literal: true

class Payment
  include ActiveModel::Model

  attr_accessor :card_number
end
