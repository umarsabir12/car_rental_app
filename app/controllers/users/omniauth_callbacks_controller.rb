# app/controllers/users/omniauth_callbacks_controller.rb
class Users::OmniauthCallbacksController < ApplicationController
  def passthru
    session[:omniauth_origin] = 'user'
    session[:oauth_nationality] = params[:nationality]
    redirect_to "/auth/google_oauth2", allow_other_host: true
  end
end