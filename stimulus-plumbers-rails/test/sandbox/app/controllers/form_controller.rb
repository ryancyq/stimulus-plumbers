# frozen_string_literal: true

class FormController < ActionController::Base
  class DemoForm
    include ActiveModel::Model
    attr_accessor :email, :name, :password, :bio, :age,
                  :birth_date, :newsletter, :gender, :country

    def self.model_name
      ActiveModel::Name.new(self, nil, "demo")
    end
  end

  layout "form"

  def sign_in
    @form = DemoForm.new
  end

  def text_fields
    @form = DemoForm.new
  end

  def password_field
    @form = DemoForm.new
  end

  def textarea
    @form = DemoForm.new
  end

  def choice_fields
    @form = DemoForm.new
  end

  def select_field
    @form = DemoForm.new
  end

  def field_states
    @form = DemoForm.new.tap do |f|
      f.errors.add(:email, "is already taken")
      f.errors.add(:name, "can't be blank")
    end
  end
end
