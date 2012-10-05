class OauthController < ApplicationController
  def callback
    list = List.where(:username => params[:username]).first
    list.create_token(params[:code])
  end
end
