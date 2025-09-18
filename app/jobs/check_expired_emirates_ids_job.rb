class CheckExpiredEmiratesIdsJob < ApplicationJob
  queue_as :default

  def perform
    Vendor.with_expired_emirates_id.find_each do |vendor|
      VendorMailer.emirates_id_expired_email(vendor).deliver_later
    end
  end
end


