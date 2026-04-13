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
  end
end
