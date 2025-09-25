class AddAdditionalMileageChargeToCar < ActiveRecord::Migration[7.2]
  def change
    add_column :cars, :additional_mileage_charge, :decimal, precision: 10, scale: 2, default: 0
  end
end
