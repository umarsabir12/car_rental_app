class AddHourlyPriceToCars < ActiveRecord::Migration[7.2]
  def change
    add_column :cars, :hourly_price, :integer
  end
end
