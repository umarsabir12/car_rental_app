class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  def after_sign_out_path_for(resource_or_scope)
    if resource_or_scope == :admin_user || (resource_or_scope.respond_to?(:mapping) && resource_or_scope.mapping == :admin_user)
      new_admin_user_session_path
    else
      root_path
    end
  end

  def after_sign_in_path_for(resource)
    user_home_path
  end

  def after_sign_up_path_for(resource)
    user_home_path
  end
end
