class EmailsController < ApplicationController
  def create
    list = List.find(params[:list_id])
    list.add_email(params)
    redirect_to params[:return]
  end
end
