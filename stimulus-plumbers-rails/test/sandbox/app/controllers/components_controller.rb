# frozen_string_literal: true

class ComponentsController < ApplicationController
  def profile; end

  def calendar_stimulus
    year  = params[:year]&.to_i
    month = params[:month]&.to_i
    @date = year && month ? Date.new(year, month, 1) : nil
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

  def combobox; end

  def search; end

  def button; end

  def list; end

  def card; end

  def popover; end

  def avatar; end

  def divider; end

  def icon; end

  def button_group; end

  def timeline; end

  private

  def parse_date(key)
    Date.parse(params[key]) if params[key]
  end
end
