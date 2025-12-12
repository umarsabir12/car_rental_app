class CreateDiscounts < ActiveRecord::Migration[7.2]
  def change
    create_table :discounts do |t|
      t.references :vendor, null: false, foreign_key: true
      t.string :category
      t.decimal :discount_percentage
      t.boolean :active

      t.timestamps
    end
  end
end
