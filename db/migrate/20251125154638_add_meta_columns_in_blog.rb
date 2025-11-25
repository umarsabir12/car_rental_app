class AddMetaColumnsInBlog < ActiveRecord::Migration[7.2]
  def change
    add_column :blogs, :meta_title, :string
    add_column :blogs, :meta_description, :string
  end
end
