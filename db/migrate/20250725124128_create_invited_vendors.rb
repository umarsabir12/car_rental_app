class CreateInvitedVendors < ActiveRecord::Migration[7.2]
  def change
    create_table :invited_vendors do |t|
      t.string :email
      t.string :first_name
      t.string :last_name
      t.string :invite_token
      t.boolean :invite_sent, default: false
      t.string :status, default: "pending"
      t.datetime :expires_at, default: 1.week.from_now

      t.timestamps
    end
  end
end
