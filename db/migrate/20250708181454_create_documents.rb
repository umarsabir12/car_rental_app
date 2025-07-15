class CreateDocuments < ActiveRecord::Migration[7.2]
  def change
    create_table :documents do |t|
      t.references :user, null: false, foreign_key: true
      t.string :doc_name
      t.string :document_type
      t.string :status, default: 'not uploaded'
      t.string :reason, default: ''

      t.timestamps
    end
  end
end
