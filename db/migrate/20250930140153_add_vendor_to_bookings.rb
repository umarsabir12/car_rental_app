class AddVendorToBookings < ActiveRecord::Migration[7.2]
  def change
    add_reference :bookings, :vendor, null: true, foreign_key: true
  end
end
