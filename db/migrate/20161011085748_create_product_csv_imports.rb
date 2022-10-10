class CreateProductCsvImports < ActiveRecord::Migration
  def change
    create_table :product_csv_imports do |t|
      t.integer :admin_id, index: true, null: false
      t.string :import_table
      t.attachment :csv_imports
      t.timestamps null: false
    end
  end
end
