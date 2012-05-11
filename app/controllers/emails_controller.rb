class EmailsController < ApplicationController
  def create
    List.find_by_name!(params[:name]).add_email(params)
  end
end
