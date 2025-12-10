class AddEmiratesIdToVendors < ActiveRecord::Migration[7.2]
  def change
    add_column :vendors, :emirates_id, :string
    add_column :vendors, :emirates_id_expires_on, :date
    add_index :vendors, :emirates_id, unique: true, where: "emirates_id IS NOT NULL"
  end
end
