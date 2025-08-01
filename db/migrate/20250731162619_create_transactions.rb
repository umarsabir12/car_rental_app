class CreateTransactions < ActiveRecord::Migration[7.2]
  def change
    create_table :transactions do |t|
      t.references :booking, null: false, foreign_key: true
      t.string :stripe_payment_intent_id
      t.string :stripe_session_id
      t.decimal :amount
      t.string :status
      t.string :transaction_type
      t.decimal :refund_amount
      t.text :refund_reason
      t.datetime :processed_at

      t.timestamps
    end
  end
end
