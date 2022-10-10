class CreateJoinTableRetailerCategories < ActiveRecord::Migration
  def change
    create_table :retailer_categories, id: false do |t|
    t.integer :retailer_id
    t.integer :category_id
    end
  end
end
