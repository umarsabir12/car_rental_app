class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  def after_sign_out_path_for(resource_or_scope)
    if resource_or_scope == :admin || (resource_or_scope.respond_to?(:mapping) && resource_or_scope.mapping == :admin)
      new_admin_session_path
    else
      root_path
    end
  end

  def after_sign_in_path_for(resource)
    if resource.is_a?(Admin)
      admin_dashboard_index_path
    elsif resource.is_a?(Vendor)
      vendors_dashboard_path
    else
      user_home_path
    end
  end

  def after_sign_up_path_for(resource)
    if resource.is_a?(Vendor)
      vendors_dashboard_path
    else
      user_home_path
    end
  end

  private

  def normalize_filter_values(values)
    values.compact
          .map(&:strip)
          .reject(&:blank?)
          .group_by(&:downcase)
          .map { |_, group| group.max_by { |v| v.scan(/[A-Z]/).size } }
          .sort
  end
end
