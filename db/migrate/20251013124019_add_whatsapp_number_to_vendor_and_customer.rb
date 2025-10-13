class AddWhatsappNumberToVendorAndCustomer < ActiveRecord::Migration[7.2]
  def change
    add_column :vendors, :whatsapp_number, :string, limit: 20
    add_column :vendors, :whatsapp_country_code, :string, limit: 3
    
    add_index :vendors, :whatsapp_number
    add_index :vendors, :whatsapp_country_code

    add_column :users, :whatsapp_number, :string, limit: 20
    add_column :users, :whatsapp_country_code, :string, limit: 3
    
    add_index :users, :whatsapp_number
    add_index :users, :whatsapp_country_code
  end
end
