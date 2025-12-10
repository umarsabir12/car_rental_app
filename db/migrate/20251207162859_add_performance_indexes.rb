class AddPerformanceIndexes < ActiveRecord::Migration[7.2]
  def change
    # Bookings indexes for analytics queries
    add_index :bookings, :created_at unless index_exists?(:bookings, :created_at)
    add_index :bookings, :status unless index_exists?(:bookings, :status)
    add_index :bookings, [ :car_id, :created_at ] unless index_exists?(:bookings, [ :car_id, :created_at ])
    add_index :bookings, [ :vendor_id, :created_at ] unless index_exists?(:bookings, [ :vendor_id, :created_at ])

    # Cars indexes for filtering and searching
    add_index :cars, :status unless index_exists?(:cars, :status)
    add_index :cars, :featured unless index_exists?(:cars, :featured)
    add_index :cars, [ :status, :featured ] unless index_exists?(:cars, [ :status, :featured ])
    add_index :cars, :category unless index_exists?(:cars, :category)
    add_index :cars, :brand unless index_exists?(:cars, :brand)
    add_index :cars, :created_at unless index_exists?(:cars, :created_at)

    # Users index for recent customers query
    add_index :users, :created_at unless index_exists?(:users, :created_at)

    # Vendors indexes for analytics
    add_index :vendors, :created_at unless index_exists?(:vendors, :created_at)
    add_index :vendors, :is_active unless index_exists?(:vendors, :is_active)

    # Invoices indexes for vendor dashboard
    add_index :invoices, :created_at unless index_exists?(:invoices, :created_at)
    add_index :invoices, [ :vendor_id, :payment_status ] unless index_exists?(:invoices, [ :vendor_id, :payment_status ])

    # Activities index for filtering by date
    add_index :activities, :created_at unless index_exists?(:activities, :created_at)
  end
end
