class CreateMustStockLists < ActiveRecord::Migration
  def change
    create_table :must_stock_lists do |t|
      t.attachment :csv_import
      t.attachment :shop_csv
      # t.attachment :product_csv
      t.timestamps
    end
  end
end
