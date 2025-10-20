class RemoveWithDriverFromCar < ActiveRecord::Migration[7.2]
  def change
    remove_column :cars, :with_driver, :boolean
  end
end
