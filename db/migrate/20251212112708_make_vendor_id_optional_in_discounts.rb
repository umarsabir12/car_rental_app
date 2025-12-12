class MakeVendorIdOptionalInDiscounts < ActiveRecord::Migration[7.2]
  def change
    change_column_null :discounts, :vendor_id, true
  end
end
