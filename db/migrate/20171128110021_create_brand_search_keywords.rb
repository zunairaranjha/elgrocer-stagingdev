class CreateBrandSearchKeywords < ActiveRecord::Migration
  def change
    create_table :brand_search_keywords do |t|
      t.string :keywords, null: false
      t.string :product_ids, null: false
      t.datetime :start_date, null: false
      t.datetime :end_date, null: false

      t.timestamps null: false
    end
  end
end