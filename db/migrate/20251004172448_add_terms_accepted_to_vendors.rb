class AddTermsAcceptedToVendors < ActiveRecord::Migration[7.2]
  def change
    add_column :vendors, :terms_accepted, :boolean, default: false
  end
end
