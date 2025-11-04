# app/controllers/omniauth_callbacks_controller.rb
class OmniauthCallbacksController < ApplicationController
  def google_oauth2
    auth = request.env['omniauth.auth']
    origin = session[:omniauth_origin]
    
    if origin == 'user'
      handle_user_callback(auth)
    elsif origin == 'vendor'
      handle_vendor_callback(auth)
    else
      redirect_to root_path, alert: 'Invalid authentication request.'
    end
    
    # Clear the session
    session.delete(:omniauth_origin)
    session.delete(:omniauth_action)
    session.delete(:oauth_nationality)
    session.delete(:oauth_terms_accepted)
  end

  def failure
    origin = session[:omniauth_origin]
    action_type = session[:omniauth_action]

    session.delete(:omniauth_origin)
    session.delete(:omniauth_action)
    session.delete(:oauth_nationality)
    session.delete(:oauth_terms_accepted)
    
    if origin == 'user'
      redirect_path = action_type == 'signin' ? new_user_session_path : new_user_registration_path
      redirect_to redirect_path, alert: 'Authentication failed. Please try again.'
    elsif origin == 'vendor'
      redirect_to new_vendor_session_path, alert: 'Authentication failed. Please try again.'
    else
      redirect_to root_path, alert: 'Authentication failed.'
    end
  end

  private

  def handle_user_callback(auth)
    # Get nationality from session
    nationality = session[:oauth_nationality]
    terms_accepted = session[:oauth_terms_accepted]
    action_type = session[:omniauth_action]
    
    @user = User.from_omniauth(auth, nationality, terms_accepted, allow_creation = action_type == 'signup')

    if @user.nil?
      # User account not found during sign-in
      redirect_to new_user_session_path, 
                  alert: 'User account not found. Please sign up first to use Google sign-in.'
    elsif @user.persisted?
      sign_in @user
      redirect_to user_home_path, notice: 'Successfully signed in with Google!'
    else
      redirect_to new_user_session_path, alert: 'Failed to sign in with Google.'
    end
  end

  def handle_vendor_callback(auth)
    @vendor = Vendor.from_omniauth(auth)
    
    if @vendor.persisted?
      sign_in @vendor
      redirect_to vendors_dashboard_path, notice: 'Successfully signed in with Google!'
    else
      redirect_to new_vendor_session_path, alert: 'Failed to sign in with Google.'
    end
  end
end