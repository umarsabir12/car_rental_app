class CreateInvoices < ActiveRecord::Migration[7.2]
  def change
    create_table :invoices do |t|
      t.references :vendor, null: false, foreign_key: true
      t.date :due_date
      t.string :payment_status, default: 'pending'
      t.string :billing_type
      t.decimal :amount, precision: 10, scale: 2
      t.date :from_date
      t.date :to_date

      t.timestamps
    end

    add_index :invoices, :payment_status
    add_index :invoices, :billing_type
  end
end
