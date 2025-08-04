class AddWithDriverToCars < ActiveRecord::Migration[7.2]
  def change
    add_column :cars, :with_driver, :boolean, default: false
  end
end
