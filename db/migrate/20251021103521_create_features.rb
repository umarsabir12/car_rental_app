class CreateFeatures < ActiveRecord::Migration[7.2]
  def change
    create_table :features do |t|
      t.string :name
      t.boolean :common, default: false

      t.timestamps
    end
    add_index :features, :name
  end
end
