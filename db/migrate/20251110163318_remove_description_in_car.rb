class RemoveDescriptionInCar < ActiveRecord::Migration[7.2]
  def change
    remove_column :cars, :description, :text
  end
end
