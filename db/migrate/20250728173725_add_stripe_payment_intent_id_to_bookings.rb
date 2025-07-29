class AddStripePaymentIntentIdToBookings < ActiveRecord::Migration[7.2]
  def change
    add_column :bookings, :stripe_payment_intent_id, :string
  end
end
