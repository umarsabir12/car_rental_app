class AddUserAndPaymentProcessedToBookings < ActiveRecord::Migration[7.2]
  def change
    add_reference :bookings, :user, null: false, foreign_key: true
    add_column :bookings, :payment_processed, :boolean
  end
end
