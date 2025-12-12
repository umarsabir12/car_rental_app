class ChangeDiscountCategoryToArray < ActiveRecord::Migration[7.2]
  def up
    # Change category column from string to text array
    change_column :discounts, :category, :text, array: true, default: [], using: 'ARRAY[category]::text[]'
  end

  def down
    # Revert back to string, taking first element of array
    change_column :discounts, :category, :string, using: 'category[1]'
  end
end
