class CreateCarFeatures < ActiveRecord::Migration[7.2]
  def change
    create_table :car_features do |t|
      t.references :car, null: false, foreign_key: true
      t.references :feature, null: false, foreign_key: true

      t.timestamps
    end
    add_index :car_features, [ :car_id, :feature_id ], unique: true
  end
end
