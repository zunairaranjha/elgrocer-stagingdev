class AddImports < ActiveRecord::Migration
  def up
    create_table :csv_imports do |t|
      t.integer :retailer_id, index: true, null: false
      t.integer :admin_id, index: true, null: false
      t.string :import_table
      t.integer :successful_inserts
      t.integer :failed_inserts
      t.timestamps
    end
    add_attachment :csv_imports, :csv_import
  end
  def down
    drop_table :csv_imports
  end
end
