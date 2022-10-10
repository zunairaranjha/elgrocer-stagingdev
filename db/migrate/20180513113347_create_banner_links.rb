class CreateBannerLinks < ActiveRecord::Migration
  def change
    create_table :banner_links do |t|
      t.integer :banner_id
      t.integer :category_id
      t.integer :subcategory_id
      t.integer :brand_id
      t.integer :priority
      t.attachment :photo

      t.timestamps null: false
    end
  end
end
