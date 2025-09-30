class ChangeAdditionalPriceTypeToInteger < ActiveRecord::Migration[7.2]
  def change
    change_column :cars, :additional_mileage_charge, :integer
  end
end
