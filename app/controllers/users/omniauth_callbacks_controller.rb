# app/controllers/users/omniauth_callbacks_controller.rb
class Users::OmniauthCallbacksController < ApplicationController
  def passthru
    session[:omniauth_origin] = "user"
    session[:omniauth_action] = params[:action_type]
    session[:oauth_nationality] = params[:nationality]
    session[:oauth_terms_accepted] = params[:terms_accepted]
    redirect_to "/auth/google_oauth2", allow_other_host: true
  end
end
