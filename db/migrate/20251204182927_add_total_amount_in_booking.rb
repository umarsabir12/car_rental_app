class AddTotalAmountInBooking < ActiveRecord::Migration[7.2]
  def change
    add_column :bookings, :total_amount, :decimal, precision: 10, scale: 2, default: 0
  end
end
