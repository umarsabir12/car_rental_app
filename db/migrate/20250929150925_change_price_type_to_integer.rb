class ChangePriceTypeToInteger < ActiveRecord::Migration[7.2]
  def change
    change_column :cars, :daily_price, :integer
    change_column :cars, :weekly_price, :integer
    change_column :cars, :monthly_price, :integer
  end
end
