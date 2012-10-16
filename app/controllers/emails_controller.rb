class EmailsController < ApplicationController
  def create
    list = List.find(params[:list_id])
    list.add_email(params)
    render :text => 'Thank you!'
  end
end
