# frozen_string_literal: true

class ComponentsController < ApplicationController
  def profile; end

  def calendar_stimulus
    year               = params[:year]&.to_i
    month              = params[:month]&.to_i
    @date              = year && month ? Date.new(year, month, 1) : Date.today
    @show_other_months = params[:show_other_months] == "true"
    @since             = parse_date(:since)
    @till              = parse_date(:till)
  end

  def calendar_turbo
    @view              = params[:view]
    @selectable        = params[:selectable] == "true"
    @show_other_months = params[:show_other_months] == "true"
    @date          = month_date_from_params(:year, :month) || Date.today
    @today         = full_date_from_params(:today_year, :today_month, :today_day) || Date.today
    @selected_date = parse_date(:selected_date)
    @since         = parse_date(:since)
    @till          = parse_date(:till)
  end

  def combobox; end

  def search; end

  def avatar; end

  def button; end

  def card; end

  def link; end

  def divider; end

  def icon; end

  def popover; end

  def timeline; end

  private

  def parse_date(key)
    Date.parse(params[key]) if params[key]
  end

  def month_date_from_params(year_key, month_key)
    year  = params[year_key]&.to_i
    month = params[month_key]&.to_i
    Date.new(year, month, 1) if year && month
  end

  def full_date_from_params(year_key, month_key, day_key)
    year  = params[year_key]&.to_i
    month = params[month_key]&.to_i
    day   = params[day_key]&.to_i
    Date.new(year, month, day) if year && month && day
  end
end
