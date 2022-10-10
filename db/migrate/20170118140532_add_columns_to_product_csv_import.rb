class AddColumnsToProductCsvImport < ActiveRecord::Migration
  def change
    add_column :product_csv_imports, :successful_inserts, :integer
    add_column :product_csv_imports, :failed_inserts, :integer
    add_attachment :product_csv_imports, :csv_failed_data
    add_attachment :product_csv_imports, :csv_successful_data
  end
end
