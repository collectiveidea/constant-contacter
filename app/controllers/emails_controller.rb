class EmailsController < ApplicationController
  def create
    List.find_by_name!(params[:name]).add_email(params)
    if params[:return].present?
      redirect_to params[:return]
    else
      render :text => 'Thank you!'
    end
  end
end
