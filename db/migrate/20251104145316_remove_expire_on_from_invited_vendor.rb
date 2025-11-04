class RemoveExpireOnFromInvitedVendor < ActiveRecord::Migration[7.2]
  def change
    remove_column :invited_vendors, :expires_at, :datetime
  end
end
