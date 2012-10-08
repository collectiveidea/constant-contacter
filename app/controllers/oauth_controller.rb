class OauthController < ApplicationController
  def callback
    auth = request.env["omniauth.auth"]
    list = List.where(:username => auth[:uid]).first
    list.save_authentication_code(auth[:credentials][:token])

    flash[:notice] = "Authentication Successful"
    redirect_to lists_url
  end
end
