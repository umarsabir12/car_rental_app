class AddPaymentModeToBookings < ActiveRecord::Migration[7.2]
  def change
    add_column :bookings, :payment_mode, :integer, default: 1, null: false
    add_index :bookings, :payment_mode
  end
end
