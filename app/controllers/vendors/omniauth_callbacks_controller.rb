# app/controllers/vendors/omniauth_callbacks_controller.rb
class Vendors::OmniauthCallbacksController < ApplicationController
  def passthru
    session[:omniauth_origin] = "vendor"
    redirect_to "/auth/google_oauth2", allow_other_host: true
  end
end
