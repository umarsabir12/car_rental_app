class Admin::EmailTestController < ApplicationController
  before_action :authenticate_admin!
  layout "admin"

  def index
  end

  def send_test
    email = params[:email]
    
    if email.present? && email.match?(/\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i)
      begin
        TestMailer.test_email(email).deliver_now
        flash[:notice] = "Test email sent successfully to #{email}!"
      rescue => e
        flash[:alert] = "Failed to send email: #{e.message}"
      end
    else
      flash[:alert] = "Please enter a valid email address"
    end
    
    redirect_to admin_email_test_index_path
  end
end
