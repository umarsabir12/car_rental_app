class AddMilleageColumnsToCars < ActiveRecord::Migration[7.2]
  def change
    add_column :cars, :daily_milleage, :integer, default: 0
    add_column :cars, :weekly_milleage, :integer, default: 0
    add_column :cars, :monthly_milleage, :integer, default: 0
  end
end


