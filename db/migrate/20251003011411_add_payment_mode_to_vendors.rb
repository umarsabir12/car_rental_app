class AddPaymentModeToVendors < ActiveRecord::Migration[7.2]
  def change
    add_column :vendors, :payment_mode, :integer, default: 1
  end
end
