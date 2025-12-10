class AddStripeFieldsToCars < ActiveRecord::Migration[7.2]
  def change
    add_column :cars, :stripe_product_id, :string
    add_column :cars, :stripe_price_id, :string

    add_index :cars, :stripe_product_id
    add_index :cars, :stripe_price_id
  end
end
