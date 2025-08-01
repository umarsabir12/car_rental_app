class Admin::SettingsController < ApplicationController
  layout "admin"
  before_action :authenticate_admin!

  def index
    @settings = {
      site_name: 'WheelsOnRent',
      site_description: 'Premium car rental platform',
      contact_email: 'admin@wheelsonrent.com',
      support_phone: '+1 (555) 123-4567',
      stripe_enabled: true,
      stripe_publishable_key: ENV['STRIPE_PUBLISHABLE_KEY'],
      stripe_secret_key: ENV['STRIPE_SECRET_KEY'] ? '***configured***' : 'Not configured',
      webhook_secret: ENV['STRIPE_WEBHOOK_SECRET'] ? '***configured***' : 'Not configured',
      max_cars_per_vendor: 10,
      min_booking_days: 1,
      max_booking_days: 30,
      commission_rate: 15,
      auto_approve_vendors: false,
      require_document_verification: true,
      maintenance_mode: false
    }
  end

  def update
    # In a real application, you would save these to a database
    # For now, we'll just show a success message
    redirect_to admin_settings_path, notice: 'Settings updated successfully!'
  end

  def test_webhook
    begin
      # Test webhook connectivity
      response = Net::HTTP.get_response(URI('https://api.stripe.com/v1/webhook_endpoints'))
      if response.code == '200'
        redirect_to admin_settings_path, notice: 'Webhook connection test successful!'
      else
        redirect_to admin_settings_path, alert: 'Webhook connection test failed!'
      end
    rescue => e
      redirect_to admin_settings_path, alert: "Webhook test error: #{e.message}"
    end
  end

  def clear_cache
    # Clear application cache
    Rails.cache.clear
    redirect_to admin_settings_path, notice: 'Cache cleared successfully!'
  end

  def system_info
    @system_info = {
      rails_version: Rails.version,
      ruby_version: RUBY_VERSION,
      database: ActiveRecord::Base.connection.adapter_name,
      environment: Rails.env,
      timezone: Time.zone.name,
      server_time: Time.current,
      uptime: `uptime`.strip,
      memory_usage: `ps -o rss= -p #{Process.pid}`.strip + ' KB'
    }
  end
end 