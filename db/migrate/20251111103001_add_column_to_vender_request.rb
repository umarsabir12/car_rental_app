class AddColumnToVenderRequest < ActiveRecord::Migration[7.2]
  def change
    add_column :vendor_requests, :company_name, :string
  end
end
