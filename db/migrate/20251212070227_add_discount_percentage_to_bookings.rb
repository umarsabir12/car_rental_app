class AddDiscountPercentageToBookings < ActiveRecord::Migration[7.2]
  def change
    add_column :bookings, :discount_percentage, :decimal
  end
end
