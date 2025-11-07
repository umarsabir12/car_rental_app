class RemoveColumnsFromInvoice < ActiveRecord::Migration[7.2]
  def change
    remove_column :invoices, :due_date, :date
    remove_column :invoices, :from_date, :date
    remove_column :invoices, :to_date, :date
    remove_column :invoices, :billing_type, :string
  end
end
