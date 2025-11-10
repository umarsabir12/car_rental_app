class UpdateColumnsInVendorRequest < ActiveRecord::Migration[7.2]
  def change
    remove_column :vendor_requests, :description, :string
    add_column :vendor_requests, :phone, :string
    add_column :vendor_requests, :vehicle_count, :integer
  end
end
