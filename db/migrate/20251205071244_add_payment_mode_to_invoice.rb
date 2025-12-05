class AddPaymentModeToInvoice < ActiveRecord::Migration[7.2]
  def change
    add_column :invoices, :payment_mode, :string, default: 'Online'
  end
end
