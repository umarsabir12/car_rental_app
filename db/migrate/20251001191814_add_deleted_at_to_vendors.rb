class AddDeletedAtToVendors < ActiveRecord::Migration[7.2]
  def change
    add_column :vendors, :deleted_at, :datetime
  end
end
