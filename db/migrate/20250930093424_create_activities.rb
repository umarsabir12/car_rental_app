class CreateActivities < ActiveRecord::Migration[7.2]
  def change
    create_table :activities do |t|
      t.references :user, null: false, foreign_key: true
      t.references :subject, polymorphic: true, null: false
      t.string :action, null: false
      t.text :description
      t.text :metadata
      t.string :ip_address
      t.string :user_agent

      t.timestamps
    end

    add_index :activities, [ :user_id, :created_at ]
    add_index :activities, [ :subject_type, :subject_id ]
    add_index :activities, :action
  end
end
