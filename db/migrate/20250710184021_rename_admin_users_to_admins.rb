class RenameAdminUsersToAdmins < ActiveRecord::Migration[7.2]
  def change
    rename_table :admin_users, :admins
  end
end
