class CreateCsvImportFailedRows < ActiveRecord::Migration
  def up
    create_table :csv_import_failed_rows do |t|
      t.integer :csv_import_id, indext: true, null: false
      t.integer :row_number
      t.string :barcode
      t.string :description
      t.string :price
    end
  end

  def down
    drop_table :csv_import_failed_rows
  end
end
