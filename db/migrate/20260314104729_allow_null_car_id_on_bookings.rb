class AllowNullCarIdOnBookings < ActiveRecord::Migration[7.2]
  def change
    change_column_null :bookings, :car_id, true
  end
end
