# frozen_string_literal: true

class ComponentsController < ApplicationController
  def profile
  end

  def calendar_stimulus
    year               = params[:year]&.to_i
    month              = params[:month]&.to_i
    @date              = year && month ? Date.new(year, month, 1) : nil
    @show_other_months = params[:show_other_months] == "true"
    @since             = parse_date(:since)
    @till              = parse_date(:till)
  end

  def calendar_turbo
    @selectable        = params[:selectable] == "true"
    @show_other_months = params[:show_other_months] == "true"
    @view              = params[:view]
    @date              = parse_date(:date) || Date.today
    @selected_date     = parse_date(:selected_date)
    @since             = parse_date(:since)
    @till              = parse_date(:till)
  end

  def combobox
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

  private

  def parse_date(key)
    Date.parse(params[key]) if params[key]
  end
end
