class CreateAnnouncements < ActiveRecord::Migration[7.2]
  def change
    create_table :announcements do |t|
      t.text :message
      t.datetime :ends_at
      t.boolean :active

      t.timestamps
    end
  end
end
