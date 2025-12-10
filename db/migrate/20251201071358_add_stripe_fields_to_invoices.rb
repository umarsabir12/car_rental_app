class AddStripeFieldsToInvoices < ActiveRecord::Migration[7.2]
  def change
    add_column :invoices, :stripe_payment_intent_id, :string
    add_column :invoices, :paid_at, :datetime
    add_column :invoices, :payment_method_id, :string
    add_column :invoices, :save_payment_method, :boolean, default: false

    add_index :invoices, :stripe_payment_intent_id, unique: true
  end
end
