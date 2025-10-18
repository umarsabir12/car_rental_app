class AddOmniauthToVendors < ActiveRecord::Migration[7.2]
  def change
    add_column :vendors, :provider, :string
    add_column :vendors, :uid, :string
  end
end
