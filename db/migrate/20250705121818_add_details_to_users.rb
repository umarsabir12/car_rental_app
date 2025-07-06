class AddDetailsToUsers < ActiveRecord::Migration[7.2]
  def change
    add_column :users, :first_name, :string
    add_column :users, :last_name, :string
    add_column :users, :phone, :string
    add_column :users, :home_address, :string
    add_column :users, :terms_accepted, :boolean
    add_column :users, :card_number, :string
    add_column :users, :card_expiry, :string
    add_column :users, :card_cvc, :string
    add_column :users, :payment_done, :boolean
  end
end
