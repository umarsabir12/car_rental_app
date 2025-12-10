class UpdateBookingStatusDefault < ActiveRecord::Migration[7.0]
  def up
    # Update the default value for new records
    change_column_default :bookings, :status, from: 'Pending', to: 'pending'

    # Update existing records to use lowercase
    execute "UPDATE bookings SET status = 'pending' WHERE status = 'Pending'"
    execute "UPDATE bookings SET status = 'confirmed' WHERE status = 'Confirmed'"
    execute "UPDATE bookings SET status = 'cancelled' WHERE status = 'Cancelled'"
  end

  def down
    # Revert the default value
    change_column_default :bookings, :status, from: 'pending', to: 'Pending'

    # Update existing records back to uppercase
    execute "UPDATE bookings SET status = 'Pending' WHERE status = 'pending'"
    execute "UPDATE bookings SET status = 'Confirmed' WHERE status = 'confirmed'"
    execute "UPDATE bookings SET status = 'Cancelled' WHERE status = 'cancelled'"
  end
end
