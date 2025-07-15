class AddVendorToCars < ActiveRecord::Migration[7.2]
  def change
    add_reference :cars, :vendor, null: true, foreign_key: true
  end
end
