class RemoveTotalMileageFromCar < ActiveRecord::Migration[7.2]
  def change
    remove_column :cars, :mileage, :integer
  end
end
