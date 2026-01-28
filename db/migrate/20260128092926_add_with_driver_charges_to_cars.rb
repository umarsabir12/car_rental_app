class AddWithDriverChargesToCars < ActiveRecord::Migration[7.2]
  def change
    add_column :cars, :five_hours_charge, :integer
    add_column :cars, :ten_hours_charge, :integer
    add_column :cars, :luggage_capacity, :integer
  end
end
