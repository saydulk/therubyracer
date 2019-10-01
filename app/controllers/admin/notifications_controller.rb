class Admin::NotificationsController < ApplicationController

  def index
    @notifications = Notification.all
  end

  def mark_as_read
    status = false
    notification_id = params[:id]
    record = Notification.find(notification_id)
    if record.update_attributes(read_at: Time.zone.now)
      status = true
    end
    render json: {success: status}
  end

end
