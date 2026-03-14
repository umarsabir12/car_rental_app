class Admin::NotificationsController < ApplicationController
  layout "admin"
  before_action :authenticate_admin!
  include Pagy::Backend if defined?(Pagy::Backend)

  def index
    # We will fetch latest 6 notifications, followed by pages if pagy is included
    base_query = current_admin.notifications.ordered

    if defined?(Pagy::Backend)
      @pagy, @notifications = pagy(base_query, items: 6)
    else
      page = (params[:page] || 1).to_i
      @notifications = base_query.offset((page - 1) * 6).limit(6)
    end

    respond_to do |format|
      format.html { render layout: false } # if called via modal or dropdown click directly
      format.turbo_stream
    end
  end

  def show
    @notification = current_admin.notifications.find(params[:id])
    @notification.mark_as_read!

    # We redirect to the path specified in the notification
    redirect_to @notification.related_path || admin_dashboard_index_path
  end

  def mark_all_read
    current_admin.notifications.unread.update_all(read_at: Time.current)
    redirect_back fallback_location: admin_dashboard_index_path, notice: "All notifications marked as read."
  end
end
