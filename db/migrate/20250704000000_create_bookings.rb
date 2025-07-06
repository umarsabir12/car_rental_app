class CreateBookings < ActiveRecord::Migration[7.2]
  def change
    create_table :bookings do |t|
      t.references :car, null: false, foreign_key: true
      t.string :name, null: false
      t.string :email, null: false
      t.date :start_date, null: false
      t.date :end_date, null: false
      t.string :status, default: 'Pending'
      t.timestamps
    end
  end
end 