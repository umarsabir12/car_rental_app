class Admin::ActivitiesController < ApplicationController
    layout "admin"
    before_action :authenticate_admin!

  def index
    @activities = Activity.includes(:user, :vendor, :subject)
                         .recent

    # Filtering
    if params[:action_filter].present?
      @activities = @activities.by_action(params[:action_filter])
    end

    if params[:user_id].present?
      @activities = @activities.by_user(User.find(params[:user_id]))
    end

    if params[:vendor_id].present?
      @activities = @activities.by_vendor(Vendor.find(params[:vendor_id]))
    end

    if params[:actor_type].present?
      case params[:actor_type]
      when 'user'
        @activities = @activities.user_activities
      when 'vendor'
        @activities = @activities.vendor_activities
      end
    end

    if params[:date_from].present?
      @activities = @activities.where('created_at >= ?', Date.parse(params[:date_from]))
    end

    if params[:date_to].present?
      @activities = @activities.where('created_at <= ?', Date.parse(params[:date_to]).end_of_day)
    end

    # Stats for the dashboard
    @stats = {
      total_activities: Activity.count,
      today_activities: Activity.where(created_at: Date.current.all_day).count,
      this_week_activities: Activity.where(created_at: 1.week.ago..Time.current).count,
      booking_activities: Activity.by_action('booking_created').count,
      document_activities: Activity.by_action('document_uploaded').count,
      payment_activities: Activity.by_action('payment_completed').count,
      user_activities: Activity.user_activities.count,
      vendor_activities: Activity.vendor_activities.count
    }

    # Recent activity types
    @activity_types = Activity.group(:action).count
  end

  def show
    @activity = Activity.find(params[:id])
  end

  def export
    @activities = Activity.includes(:user, :subject).recent

    respond_to do |format|
      format.csv do
        send_data generate_csv(@activities), 
                  filename: "activities_#{Date.current.strftime('%Y%m%d')}.csv",
                  type: 'text/csv'
      end
    end
  end

  private

  def generate_csv(activities)
    require 'csv'
    
    CSV.generate(headers: true) do |csv|
      csv << ['ID', 'User', 'Action', 'Description', 'Subject Type', 'Subject ID', 'Created At', 'IP Address']
      
      activities.each do |activity|
        csv << [
          activity.id,
          activity.user.full_name,
          activity.action,
          activity.description,
          activity.subject_type,
          activity.subject_id,
          activity.created_at.strftime('%Y-%m-%d %H:%M:%S'),
          activity.ip_address
        ]
      end
    end
  end
end
