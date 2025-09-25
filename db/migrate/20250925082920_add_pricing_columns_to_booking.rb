class AddPricingColumnsToBooking < ActiveRecord::Migration[7.2]
  def change
    add_column :bookings, :selected_period, :string
    add_column :bookings, :selected_price, :decimal, precision: 10, scale: 2
    add_column :bookings, :selected_mileage_limit, :integer
  end
end
