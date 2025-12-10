class RenamePriceAddWeeklyMonthlyToCars < ActiveRecord::Migration[7.2]
  def change
    rename_column :cars, :price, :daily_price
    add_column :cars, :weekly_price, :decimal, precision: 10, scale: 2
    add_column :cars, :monthly_price, :decimal, precision: 10, scale: 2
  end
end
