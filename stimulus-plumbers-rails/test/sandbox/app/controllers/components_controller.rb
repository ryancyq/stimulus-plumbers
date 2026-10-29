# frozen_string_literal: true

class ComponentsController < ApplicationController
  def profile
  end

  def calendar_inline
  end

  def combobox
  end

  CITIES = [%w[Seoul se], %w[Seville sv], %w[Singapore sg], %w[Stockholm st], %w[Sydney sy]].freeze

  def combobox_cities
    query   = params[:q].to_s.downcase
    @cities = CITIES.select { |label, _| label.downcase.start_with?(query) }
  end

  def search
  end

  def button
  end

  def list
  end

  def ordered_list
  end

  def card
  end

  def popover
  end

  def modal
  end

  def modal_turbo
  end

  def modal_form
    @modal_form_frame = request.headers["Turbo-Frame"] == "modal"
    @modal_form_saved = params[:saved] == "true"
    render :modal_form, layout: false if @modal_form_frame
  end

  def modal_form_submit
    @modal_form_frame = request.headers["Turbo-Frame"] == "modal"
    if params[:name].blank?
      @modal_form_error = "Name is required"
      render :modal_form, layout: !@modal_form_frame, status: :unprocessable_entity
    else
      redirect_to "/components/modal/form?saved=true", status: :see_other
    end
  end

  def avatar
  end

  def divider
  end

  def icon
  end

  def button_group
  end

  def timeline
  end

  def progress
  end

  def indicator
  end
end
