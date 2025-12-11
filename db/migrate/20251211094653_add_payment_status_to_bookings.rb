class AddPaymentStatusToBookings < ActiveRecord::Migration[7.2]
  def change
    add_column :bookings, :payment_status, :string, default: "pending"

    # Migrate existing data: set payment_status based on payment_processed flag
    reversible do |dir|
      dir.up do
        execute <<-SQL
          UPDATE bookings
          SET payment_status = CASE
            WHEN payment_processed = true THEN 'paid'
            ELSE 'pending'
          END
        SQL
      end
    end
  end
end
