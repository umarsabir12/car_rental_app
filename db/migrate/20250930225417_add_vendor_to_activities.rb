class AddVendorToActivities < ActiveRecord::Migration[7.2]
  def change
    add_reference :activities, :vendor, null: true, foreign_key: true
  end
end
