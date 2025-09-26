class CreateCarDocuments < ActiveRecord::Migration[7.2]
  def change
    create_table :car_documents do |t|
      t.references :car, null: false, foreign_key: true
      t.integer :document_status, default: 0
      t.timestamps
    end
  end
end
