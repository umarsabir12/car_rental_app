# lib/tasks/update_expire_status.rake
namespace :update_expire_status do
  desc "Update Expire Status In Invited Vendors"
  task seed: :environment do
    puts "Starting to update expired status"

    count = 0

    InvitedVendor.where(status: 'expired').each do | invited_vendor |
      if Vendor.find_by_email(invited_vendor.email)
        invited_vendor.update(status: 'accepted', invite_token: nil)
        count += 1
      else
        invited_vendor.update(status: 'pending')
        count += 1
      end
    end
    
    puts "\n" + "="*50
    puts "Updated #{count} Expired invites"
    puts "Expired Invites updating completed!"
    puts "="*50
  end
end