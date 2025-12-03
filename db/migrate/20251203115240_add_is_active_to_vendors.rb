class AddIsActiveToVendors < ActiveRecord::Migration[7.2]
  def change
    add_column :vendors, :is_active, :boolean, default: true
  end
end
