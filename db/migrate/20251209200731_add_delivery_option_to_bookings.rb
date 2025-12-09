class AddDeliveryOptionToBookings < ActiveRecord::Migration[7.2]
  def change
    add_column :bookings, :delivery_option, :string
  end
end
