class MakeUserIdNullableInActivities < ActiveRecord::Migration[7.2]
  def change
    change_column_null :activities, :user_id, true
  end
end
