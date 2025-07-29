class AddStripeSessionIdToBookings < ActiveRecord::Migration[7.2]
  def change
    add_column :bookings, :stripe_session_id, :string
  end
end
