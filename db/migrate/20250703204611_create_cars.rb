class CreateCars < ActiveRecord::Migration[7.2]
  def change
    create_table :cars do |t|
      t.string  :model
      t.string  :brand
      t.string  :category
      t.string  :color
      t.integer :year
      t.decimal :price, precision: 10, scale: 2
      t.string  :status
      t.text    :description
      t.string  :main_image_url

      # Feature Columns
      t.string  :transmission
      t.string  :fuel_type
      t.integer :seats
      t.integer :mileage
      t.string  :engine_size

      t.boolean :air_conditioning, default: true
      t.boolean :gps, default: false
      t.boolean :sunroof, default: false
      t.boolean :bluetooth, default: false
      t.integer :usb_ports, default: 2

      t.boolean :featured, default: false

      t.timestamps
    end
  end
end
