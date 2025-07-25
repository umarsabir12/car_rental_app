class AddFirstNameAndLastNameToVendors < ActiveRecord::Migration[7.2]
  def change
    add_column :vendors, :first_name, :string
    add_column :vendors, :last_name, :string
    remove_column :vendors, :name
  end
end
