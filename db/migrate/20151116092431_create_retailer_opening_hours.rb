class CreateRetailerOpeningHours < ActiveRecord::Migration
  def change
    create_table :retailer_opening_hours do |t|
    	t.integer :retailer_id, index: true, null: false
    	t.integer :day, null: false
    	t.column :open, :integer, null: false
    	t.column :close, :integer, null: false
    end
  end
end
