class CreateVendorRequests < ActiveRecord::Migration[7.2]
  def change
    create_table :vendor_requests do |t|
      t.string :email
      t.string :first_name
      t.string :last_name
      t.integer :status, default: 0
      t.timestamps
    end
  end
end
