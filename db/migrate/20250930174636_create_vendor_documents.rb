class CreateVendorDocuments < ActiveRecord::Migration[7.2]
  def change
    create_table :vendor_documents do |t|
      t.references :vendor, null: false, foreign_key: true
      t.integer :document_status, default: 0
      t.timestamps
    end
  end
end
