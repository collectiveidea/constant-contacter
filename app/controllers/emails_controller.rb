class EmailsController < ApplicationController
  def create
    List.add_email(params)
    render :text => 'Thank you!'
  end
end
