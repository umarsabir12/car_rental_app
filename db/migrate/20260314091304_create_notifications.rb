class CreateNotifications < ActiveRecord::Migration[7.2]
  def change
    create_table :notifications do |t|
      t.references :admin, null: false, foreign_key: true
      t.string :title
      t.string :message
      t.string :related_path
      t.datetime :read_at

      t.timestamps
    end
  end
end
