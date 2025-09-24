class AddInsuranceToCar < ActiveRecord::Migration[7.2]
  def up
    add_column :cars, :insurance_policy, :string, default: ""
  end
end
