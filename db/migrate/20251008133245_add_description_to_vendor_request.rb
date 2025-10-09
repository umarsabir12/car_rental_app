class AddDescriptionToVendorRequest < ActiveRecord::Migration[7.2]
  def change
    add_column :vendor_requests, :description, :string, default: ""
  end
end
