class Admin::AnnouncementsController < ApplicationController
  layout "admin"
  before_action :authenticate_admin!
  before_action :set_announcement

  def show
    # Redirect to edit since we only have one announcement
    redirect_to edit_admin_announcement_path
  end

  def edit
  end

  def update
    if @announcement.update(announcement_params)
      redirect_to edit_admin_announcement_path, notice: "Announcement updated successfully."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @announcement.update(message: nil, ends_at: nil, active: false)
    redirect_to edit_admin_announcement_path, notice: "Announcement cleared."
  end

  private

  def set_announcement
    @announcement = Announcement.current
  end

  def announcement_params
    params.require(:announcement).permit(:message, :ends_at, :active)
  end
end
