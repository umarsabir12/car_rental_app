class AddBookingsCountToCars < ActiveRecord::Migration[7.2]
  def change
    add_column :cars, :bookings_count, :integer, default: 0, null: false

    # Populate existing counts
    Car.find_each do |car|
      Car.reset_counters(car.id, :bookings)
    end
  end
end
