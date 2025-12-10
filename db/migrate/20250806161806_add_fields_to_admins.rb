class AddFieldsToAdmins < ActiveRecord::Migration[7.2]
  def change
    add_column :admins, :first_name, :string
    add_column :admins, :last_name, :string
    add_column :admins, :role_type, :string, default: 'admin'

    # Add index for better performance
    add_index :admins, :role_type
  end
end
