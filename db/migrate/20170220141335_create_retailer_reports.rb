class CreateRetailerReports < ActiveRecord::Migration
  def change
    create_table :retailer_reports do |t|
      t.string :name
      t.integer :retailer_id
      t.integer :export_total
      t.datetime :from_date
      t.datetime :to_date
      t.attachment :file1
      t.attachment :file2

      t.timestamps null: false
    end
  end
end
