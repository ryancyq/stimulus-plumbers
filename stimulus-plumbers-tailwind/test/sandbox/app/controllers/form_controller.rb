# frozen_string_literal: true

class FormController < ApplicationController
  def sign_up
    @form = SignUp.new
  end

  def choices
    @form = SignUp.new
  end

  def single_checkbox
    @form = SignUp.new
  end

  def collection_checkbox
    @form = SignUp.new
  end

  def collection_radio
    @form = SignUp.new
  end

  def field_error
    @form = SignUp.new.tap do |f|
      f.errors.add(:email, "is already taken")
      f.errors.add(:name, "can't be blank")
    end
  end

  def fieldset
    @form = SignUp.new.tap do |f|
      f.errors.add(:gender, "can't be blank")
      f.errors.add(:interests, "must select at least one")
    end
  end

  def floating_label
    @error_form = SignUp.new.tap { |f| f.errors.add(:name, "can't be blank") }
  end

  def code
    @form = SignUp.new
  end

  def credit_card
    @form = SignUp.new
  end
end
