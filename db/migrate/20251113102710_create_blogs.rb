class CreateBlogs < ActiveRecord::Migration[7.2]
  def change
    create_table :blogs do |t|
      t.string :author_name
      t.string :title
      t.string :slug
      t.string :content
      t.string :category
      t.datetime :published_at

      t.timestamps
    end
  end
end
